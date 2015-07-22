require 'net/ftp'

namespace :heritage do

  desc "Prints Template.all and Plan.all in a seeds.rb way."
  task :export_seeds => :environment do
    Template.order(:id).all.each do |template|
      puts "Template.create(#{template.serializable_hash.delete_if {|key, value| ['created_at','updated_at'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
    Plan.order(:id).all.each do |plan|
      puts "Plan.create(#{plan.serializable_hash.delete_if {|key, value| ['created_at','updated_at'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end

  desc "Generate the final Pdf cookbooks that have been paid for"
  
  task generate_final_pdfs: :environment do

    # Get paid orders to process
    puts ">>  Process orders"
    orders = Order.where('
      paid_on IS NOT NULL AND 
      generated_at IS NULL AND 
      reorder_id IS NULL
    ')

    if orders.empty?
      puts "    No orders to process."
      exit 0
    else
      puts "    Found #{orders.count} orders to process."

      # Notify operators cookbook's order generation start
      AdministrativeMailer.final_pdf_uploading_started(orders).deliver

      # Process each orders
      orders.each do |order|

        puts ">>  Process order ##{order.id} - cookbook ##{order.cookbook.id}"

        # Generate the PDF document
        begin
          print "    Rendering '#{order.cookbook.title}' by #{order.cookbook.owner.first_name} #{order.cookbook.owner.last_name}... "
          order.generated_at = Time.now
          order.filename     = "cookbook_#{order.id}_#{order.cookbook.id}-#{order.generated_at.strftime("%H_%M_%d_%m_%Y")}.pdf"
          path               = "#{PDF_IMAGES_PATH}/#{order.filename}"
          order.cookbook.render_final path
          puts "done."
        rescue Exception => e
          puts "error."
          puts " !  #{e.message}"
          puts ""
          puts e.backtrace
          puts ""
        end

        # Upload it to the printing service FTP
        if !File.exist? path
          "    '#{order.filename}' not found."
        else

          # Verify the file is not empty (rendering error)
          if File.zero? path
            "    '#{order.filename}' is empty."

          else
            begin
            
              print "    Sending the PDF document to the printing service... "
              Net::FTP.open(HUME_FTP_HOSTNAME) do |ftp|
                ftp.login HUME_FTP_USERNAME, HUME_FTP_PASSWORD
                ftp.passive = true
                ftp.binary  = true
                ftp.chdir HUME_FTP_REMOTE_FOLDER
                ftp.putbinaryfile(path, order.filename)
              end
              puts "done."

              # Notify operators the cookbook has been delivered
              # and unlock the cookbook
              AdministrativeMailer.final_pdf_uploaded(order).deliver
              order.cookbook.update_attribute(:is_locked_for_printing, false)

              # Save the order state
              if order.save
                puts ">>  Done."
              else
                puts " !  The order ##{order.id} cannot be saved."
                puts ""
                puts order.to_yaml
                puts ""
              end
            
            rescue Exception => e
              puts "error."
              puts " !  #{e.message}"
              puts ""
              puts e.backtrace
              puts ""
            end
          end
        end
      end
    end
  end

  desc "Sending notice emails to users about to expire their free trial"
  task send_free_trial_expiry_emails: :environment do
    
    puts ">>  Sending notice emails to users about to expire their free trial"

    if !ENV["DAYS"]
      puts "    No days specified."
      puts "    Usage: rake heritage_maintenance:send_expiry_emails DAYS=x,y,z"
      exit 1
    else
      days = ENV['DAYS'].split(',')

      days.each do |number|
        puts ">>  Free Trial Accounts: #{number} days left"

        # Found concerned users
        users = User.where(
          plan_id: 1,
          expiry_date: Date.today + number.to_i
        ).order("expiry_date")

        if users.empty?
          puts "    No user concerned."
        else
          puts "    Found #{users.count} users concerned."

          # Send an email for each users
          users.each do |user|
            begin
              print "    Sending expiry notice to '#{user.email}'... "
              AccountMailer.send("expiry_notice_#{number}", user).deliver
              puts "done."
            rescue Exception => e
              puts "error."
              puts " !  Cannot send the expiry notice - #{e.message}"
              puts ""
              puts e.backtrace
              puts ""
            end
          end
        end
      end
    end
  end

  desc "Sharing a recipe by email"
  task share_recipe: :environment do
    
    puts ">>  Sharing recipes by email"

    # Verify we have a recipe ID
    if !ENV["RECIPE_ID"]
      puts "    No recipe specified."
      puts "    Usage: rake heritage:share_recipe RECIPE_ID=XXXX"
      exit 1
    end

    # If no mail is given, send to the environment configured email
    recipient = ENV["EMAIL"]
    if !recipient
      puts "  ! No email specified, use default email (#{WORDPRESS_API_EMAIL})"
      recipient = WORDPRESS_API_EMAIL
    end
    
    recipe_ids = ENV["RECIPE_ID"].split(",")

    recipe_ids.each do |recipe_id|

      # Get the recipe and the author
      recipe = Recipe.find recipe_id
      contributor = recipe.user
      author = recipe.section.cookbook.owner

      puts ">>  Sharing '#{recipe.name.capitalize}' added by #{author.name}"

      # Alert the user if the author has not authorized heritage to publy its recipe
      if recipe.shared == 0
        puts "  ! The author has not allowed this recipe to be shared"
      end

      # Get a list of capitalized ingredients
      ingredients = []
      recipe.ingredient_list.each_line do |line|
        ingredients << line
      end

      # Parse the list of ingredients with wordpress tags
      csv_tags = Rails.root.join("config/wordpress_tags.csv").to_s
      parser = TagsParser.new csv_tags
      tags = parser.match *ingredients

      if tags.any?
        puts "    Tags: #{tags.join(", ")}"
      else
        puts "  ! No tags found by the parser"
      end

      # Sending the email
      puts "    Last edited on: #{recipe.updated_on}"
      puts "    Sending by email to: #{recipient}"
      email = WordpressMailer.recipe(
        to: recipient,
        title: recipe.name,
        section: recipe.section.name,
        ingredients: recipe.ingredient_list,
        instructions: recipe.instructions,
        author: author.name,
        author_display_name: author.first_name_last_name_initial,
	contributor_display_name:contributor.first_name_last_name_initial,
	contributor_email:contributor.email,
	author_email: author.email,
        author_state: author.state,
        author_city: author.city,
        tags: tags
      )
      email.deliver
    end
    puts ">>  Done."
  end

  desc "Sending notice emails to users about to expire their paid account"
  task send_account_expiry_emails: :environment do

    puts ">>  Sending notice emails to users about to expire their paid account"

    if !ENV["DAYS"]
      puts "    No days specified."
      puts "    Usage: rake heritage_maintenance:send_account_expiry_emails DAYS=x,y,z"
      exit 1
    else    

      days = ENV['DAYS'].split(',')
      days.each do |number|
        puts ">>  Paid Accounts: #{number} days left"

        # Found concerned users
        User.find(:all, :conditions => ["plan_id NOT IN (1, 5) AND expiry_date = ?", Date.today + number.to_i], :order => "expiry_date")
        users = User.where('
          plan_id NOT IN (1, 5) AND 
          expiry_date = ?
        ', Date.today + number.to_i).order("expiry_date")

        if users.empty?
          puts "    No user concerned."
        else
          puts "    Found #{users.count} users concerned."

          # Send an email for each users
          users.each do |user|
            begin
              print "    Sending expiry notice to '#{user.email}'... "
              AccountMailer.send("paid_account_expiry_notice_#{number}", user).deliver
              puts "done."
            rescue Exception => e
              puts "error."
              puts " !  Cannot send the expiry notice - #{e.message}"
              puts ""
              puts e.backtrace
              puts ""
            end
          end
        end
      end
    end
  end
end
