namespace :devops do

  # Recipes length are cached in database each time a recipe is modified.
  # If any change is made on the length calculation process, these change are not applied to already cached length.
  # This can be a problem with half page recipe becoming one page recipe after an update on the length calculation process.
  # This task recount all half page recipe between a date range (1 month from now per default) and update the value if specified (SAVING=true).
  # Output are logged into the `log/verify_half_page_recipe.log` file.
  # Options:
  # * START_AT= Start the date range at (default: 1 month ago)
  # * END_AT= End the date range at (default: now)
  # * SAVING= Save the changes in databases (default: false)
  # * VERBOSE= Display output on STDOUT too (default: false)
  desc "Recount all half page recipes last modified between a time range."
  task :verify_half_page_recipes => :environment do

    puts ">> Recount all half page recipes last modified between a time range" if verbose?
    log = Logger.new Rails.root.join('log', 'verify_half_page_recipes.log')

    # Define our date range
    start_at = (ENV['START_AT']) ? Date.parse(ENV['START_AT']).to_time : 1.month.ago
    end_at = (ENV['END_AT']) ? Date.parse(ENV['END_AT']).to_time : Time.now
    puts ">> Between #{start_at} and #{end_at}" if verbose?

    # Get all half recipes modified between our date range
    recipes = Recipe.where(updated_on: start_at..end_at, pages: 0.5).order(:updated_on)
    counter = recipes.length
    counter_length = counter.to_s.length
    puts ">> Found #{counter} recipes to verify" if verbose?
    log.info ""
    log.info "[#{counter}] Verify #{counter} recipes from #{start_at} to #{end_at} ----------------------------------------------------------------"

    updated_counter = 0
    recipes.each do |recipe|
      old_length = recipe.pages
      recipe.get_length
      new_length = recipe.pages

      # If the calculated length is different log and update the recipe length cache
      if old_length != new_length
        logline = "[#{counter.to_s.rjust(counter_length)}] - #{recipe.updated_on} - Recipe ##{recipe.id} pages length has been updated: #{old_length} to #{new_length}"
        log.info logline
        puts "   #{logline}" if verbose?
        recipe.update_attribute(:pages, new_length) if saving?
        updated_counter += 1
      end

      counter -= 1
    end

    puts ">> Done, #{updated_counter} recipes updated." if verbose?
    log.info "[#{counter.to_s.rjust(counter_length)}] #{updated_counter} recipes updated."
  end

  private

  # Tell if the user ask the change to be saved in database
  def saving?
    (ENV['SAVING'] == 'true')
  end

  # Tell if the user want to have an SDOUT output
  def verbose?
    (ENV['VERBOSE'] == 'true')
  end
end