namespace :cookbook do
  
  desc "Generate a cookbook in preview version"
  task preview: :environment do 
    puts ">>  Generate a cookbook preview"

    # Get the cookbook
    @cookbook = find_cookbook

    # Generate the PDF document
    begin
      print "    Rendering '#{@cookbook.title}' by #{@cookbook.owner.first_name} #{@cookbook.owner.last_name}..."
      path = "#{PDF_PREVIEW_FOLDER}/preview_#{@cookbook.id}_#{Time.now.to_i}.pdf"
      @cookbook.render_preview path
      puts ""
      puts "    Done: #{path}"
    rescue Exception => e
      puts " !  Error: #{e.message}"
      puts ""
      puts e.backtrace
      exit 1
    end
  end

  desc "Generate a cookbook in final version"
  task final: :environment do
    puts ">>  Generate a cookbook"

    # Get the cookbook
    @cookbook = find_cookbook

    # Generate the PDF document
    begin
      print "    Rendering '#{@cookbook.title}' by #{@cookbook.owner.first_name} #{@cookbook.owner.last_name}..."
      path = "#{PDF_IMAGES_PATH}/cookbook_#{ENV['ORDER_ID'] || "0000"}_#{@cookbook.id}-#{Time.now.strftime("%H_%M_%d_%m_%Y")}.pdf"
      @cookbook.render_final path
      puts ""
      puts "    Done: #{path}"
    rescue Exception => e
      puts ""
      puts " !  Error: #{e.message}"
      puts ""
      puts e.backtrace
      exit 1
    end
  end

  # Task to recount all recipes (or just one if a recipe ID is provided) of a cookbook
  # Do not save the new page length number by default (use SAVING=true to save the new length)
  # Also display summary of non valid recipes after the recount
  desc "Recount all the recipes length for a cookbook"
  task recount: :environment do
    puts ">>  Recount all recipes length for a cookbook"

    saving = (ENV["SAVING"])
    puts ">>  Do not save changes (add SAVING=true to save the new count)" if !saving

    # Get the cookbook
    cookbook = find_cookbook
    puts ">>  Cookbook ##{cookbook.id} - '#{cookbook.title}' by #{cookbook.owner.name}"
    unvalid_recipes = []

    only_this_recipe = ENV["RECIPE_ID"]

    if only_this_recipe
      recipe = Recipe.find  only_this_recipe
      unvalid_recipes += recount_page_length(recipe, saving)
    else

      cookbook.sections.each do |section|
        
        section.recipes.each do |recipe|

          unvalid_recipes += recount_page_length(recipe, saving)  
        end
      end
    end

    if unvalid_recipes.any?
      puts ">>  Non-valid recipes"
      unvalid_recipes.each do |recipe|
        puts "    ##{recipe.id} - #{recipe.name} (section: #{recipe.section.name})"
        recipe.errors.full_messages.each do |msg|
          puts "    * #{msg}"
        end
      end
    end
  end

  desc "List and count missing images on a cookbook"
  task missing_images: :environment do
    puts ">>  Detect missing images"

    ENV['SKIP_IMAGE_NOT_FOUND'] = "true"

    # Get the cookbook
    @cookbook = find_cookbook
    puts "    Cookbook: '#{@cookbook.title}' by #{@cookbook.owner.first_name} #{@cookbook.owner.last_name} (##{@cookbook.id})"

    output = StringIO.new
    stdout, $stdout = $stdout, output
    Dir.mktmpdir do |tmpdir|
      path = "#{tmpdir}/#{@cookbook.id}.pdf"
      @cookbook.render_final path
    end
    $stdout = stdout
    
    counter = 0
    output.string.each_line do |line|
      counter += 1
      puts "  * #{line}"
    end

    puts "    Done: #{counter} missing images found."
  end

  desc "Find and count every missing images in Paperclip"
  task missing_paperclip_attachment: :environment do
    puts ">>  Detect missing paperclip attachment"

    counter = 0

    ['Cookbook', 'Recipe', 'ExtraPage', 'Section'].each do |class_name|
      puts ">>  Class: #{class_name}"

      ENV['CLASS'] = class_name
      klass = Paperclip::Task.obtain_class
      names = Paperclip::Task.obtain_attachments(klass)
      names.each do |name|
        Paperclip.each_instance_with_attachment(klass, name) do |instance|
          if instance.send("#{name}?")
            begin
              open(instance.send(name).url)
            rescue
              counter += 1
              puts "  * (#{counter}) [#{last_update(instance)}] #{instance.send(name).url}"
            end
          end
        end
      end
    end
    puts "    Done: #{counter} missing paperclip attachment found."
  end

  desc "Find and count every missing images in Paperclip in a date range"
  task missing_cookbooks_images: :environment do
    puts ">>  Detect missing cookbooks images"
    cookbooks = []
    if ENV["COOKBOOK_IDS"]
      ENV["COOKBOOK_IDS"].split(',').each do |id|
        cookbooks << Cookbook.find(id.to_i)
      end
      puts "    #{cookbooks.count} was specified"
    else
      cookbooks = Cookbook.where('updated_on > ?', DateTime.now - 1.month)
      puts "    #{cookbooks.count} was updated in the last month"
    end

    cookbooks.each do |cookbook|
      puts ">>  Cookbook ##{cookbook.id}"
      missing = {
        cookbook: [],
        section: [],
        recipe: [],
        extra_page: []
      }

      puts "    Scanning cookbook images..."
      ["user_image", "user_cover_image", "user_inner_cover_image", "intro_image"].each do |image|
        if cookbook.send("#{image}?")
          missing[:cookbook] << cookbook.send(image).url if !image_exist? cookbook.send(image).url
        end
      end
      puts (missing[:cookbook].empty?) ? "    Done: ok" : "    Done: #{missing[:cookbook].count} missing!"

      puts "    Scanning sections images..."
      cookbook.sections.each do |section|
        if section.photo?
          missing[:section] << url if !image_exist? section.photo.url
        end
      end
      puts (missing[:section].empty?) ? "    Done: ok" : "    Done: #{missing[:section].count} missing!"

      puts "    Scanning recipes images..."
      cookbook.recipes.each do |recipe|
        if recipe.photo?
          missing[:recipe] << recipe.photo.url if !image_exist? recipe.photo.url
        end
      end
      puts (missing[:recipe].empty?) ? "    Done: ok" : "    Done: #{missing[:recipe].count} missing!"

      puts "    Scanning extra pages..."
      cookbook.extra_pages.each do |extra_page|
        if extra_page.photo?
          missing[:extra_page] << extra_page.photo.url if !image_exist? extra_page.photo.url
        end
      end
      puts (missing[:extra_page].empty?) ? "    Done: ok" : "    Done: #{missing[:extra_page].count} missing!"
    end
  end

  private

  # Recount the length of the given recipe
  # Return an array of the non-validated recipe (empty if any)
  def recount_page_length(recipe, saving)
    unvalid_recipe = []
    old_length = recipe.pages
    recipe.get_length
    new_length = recipe.pages

    if old_length != new_length && recipe.force_own_page != 1
      recipe.update_column(:pages, new_length) if saving
      puts "    #{recipe.section.name} / #{recipe.name}: #{old_length} -> #{new_length}"
    end

    unvalid_recipe << recipe if !recipe.valid?
    return unvalid_recipe
  end

  def image_exist?(image_url)
    begin
      print "    * #{image_url}"
      open image_url
      puts " (found)"
      return true
    rescue
      puts " (not found)" 
      return false
    end
  end

  def last_update(instance)
    last_updated = 'Unknown'

    if defined? instance.updated_at
      updated_at = instance.updated_at
      last_updated = (updated_at.nil?) ? 'Unknown' : updated_at
    elsif defined? instance.updated_on
      updated_on = instance.updated_on
      last_updated = (updated_on.nil?) ? 'Unknown' : updated_on
    end
      
    return last_updated
  end

  # Get a cookbook
  def find_cookbook
    if ENV["COOKBOOK_ID"]
      begin 
        @cookbook = Cookbook.find(ENV["COOKBOOK_ID"])
      rescue
        puts " !  No cookbook found with this id - #{ENV['COOKBOOK_ID']}"
        exit 1
      end
    else
      puts " !  No cookbook specified"
      puts "    Usage: rake cookbook:preview COOKBOOK_ID=1234 [ORDER_ID=0000]"
      exit 1
    end
  end
end