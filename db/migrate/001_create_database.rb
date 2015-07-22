class CreateDatabase < ActiveRecord::Migration
	def self.up
		create_table "authorships" do |t|
			t.column "user_id", :integer
			t.column "cookbook_id", :integer
			t.column "role", :integer, :default => 1, :null => false
		end
		
		create_table "comatose_pages" do |t|
			t.column "parent_id", :integer
			t.column "full_path", :text
			t.column "title", :string
			t.column "slug", :string
			t.column "body", :text
			t.column "author", :string
			t.column "position", :integer, :default => 0
			t.column "updated_on", :datetime
			t.column "filter_type", :string, :limit => 25, :default => "Textile"
			t.column "keywords", :text
		end
		
		create_table "cookbooks" do |t|
			t.column "intro_type", :integer, :default => 0, :null => false
			t.column "intro_text", :text, :default => '', :null => false
			t.column "template_id", :integer, :default => 0, :null => false
			t.column "title", :string, :default => '', :null => false
			t.column "user_image", :string, :default => '', :null => false
			t.column "user_title_image", :string, :default => '', :null => false
			t.column "tag_line_1", :string, :default => '', :null => false
			t.column "tag_line_2", :string, :default => '', :null => false
			t.column "tag_line_3", :string, :default => '', :null => false
			t.column "tag_line_4", :string, :default => '', :null => false
			t.column "custom_tag_line_1", :string, :default => '', :null => false
			t.column "custom_tag_line_2", :string, :default => '', :null => false
			t.column "custom_tag_line_3", :string, :default => '', :null => false
			t.column "custom_tag_line_4", :string, :default => '', :null => false
			t.column "grayscale", :integer, :default => 0, :null => false
		end
		
		create_table "plans" do |t|
			t.column "title", :string, :default => '', :null => false
			t.column "duration", :integer, :default => 0, :null => false
			t.column "price", :float, :default => 0, :null => false
			t.column "number_of_books", :integer, :default => 0, :null => false
			t.column "purchaseable", :integer, :default => 1
		end
		
		create_table "recipes" do |t|
			t.column "section_id", :integer, :default => 0, :null => false
			t.column "name", :string, :limit => 100, :default => '', :null => false
			t.column "servings", :string, :limit => 40, :default => "1 Person", :null => false
			t.column "ingredient_list", :text, :default => '', :null => false
			t.column "instructions", :text, :default => '', :null => false
			t.column "story", :text, :default => '', :null => false
			t.column "photo", :string, :default => '', :null => false
			t.column "position", :integer, :default => 1, :null => false
			t.column "user_id", :integer, :default => 0, :null => false
			t.column "grayscale", :integer, :default => 0, :null => false
			t.column "pages", :float, :default => 0.0, :null => false
			t.column "submitted_by", :string, :limit => 50, :default => '', :null => false
			t.column "shared", :integer, :default => 0, :null => false
			t.column "created_on", :datetime
			t.column "updated_on", :datetime
		end
		
		create_table "sections" do |t|
			t.column "cookbook_id", :integer, :default => 0, :null => false
			t.column "name", :string, :limit => 25, :default => '', :null => false
			t.column "position", :integer, :default => 0, :null => false
		end
		
		create_table "sessions" do |t|
			t.column "session_id", :string
			t.column "data", :text
			t.column "updated_at", :datetime
		end
		
		add_index "sessions", ["session_id"], :name => "sessions_session_id_index"
		
		create_table "templates" do |t|
			t.column "name", :string, :limit => 50, :default => '', :null => false
			t.column "config_file", :string, :limit => 50, :default => '', :null => false
			t.column "template_type", :integer, :default => 1, :null => false
			t.column "has_image", :integer, :default => 0, :null => false
			t.column "tag_lines", :integer, :default => 0, :null => false
			t.column "description", :text
		end
		
		create_table "users" do |t|
			t.column "first_name", :string, :limit => 50, :default => '', :null => false
			t.column "last_name", :string, :limit => 50, :default => '', :null => false
			t.column "address", :string, :limit => 50, :default => '', :null => false
			t.column "zip", :string, :limit => 10, :default => '', :null => false
			t.column "state", :string, :limit => 100, :default => '', :null => false
			t.column "phone", :string, :limit => 15, :default => '', :null => false
			t.column "email", :string, :limit => 100, :default => '', :null => false
			t.column "hashed_password", :string, :limit => 40, :default => '', :null => false
			t.column "country", :string, :limit => 50, :default => '', :null => false
			t.column "address2", :string, :default => '', :null => false                 
			t.column "city", :string, :default => '', :null => false
			t.column "how_heard", :string, :default => '', :null => false
			t.column "newsletter", :string, :default => '', :null => false
			t.column "cookbook_type", :string, :default => '', :null => false
			t.column "plan_id", :integer
			t.column "expiry_date", :date
			t.column "confirm_key", :string, :limit => 40
		end
	
		puts
		print "# Adding Comatose initial page ..."
		ComatosePage.create( :title=>'Home Page', :body=>'Your content goes here...', :author=>'Comatose' )
		puts "OK
"
		print "# Adding Templates ..."
		Template.create(  :name =>          'Our Family Cookbook 1', 
						  :template_type=>	1,
						  :has_image =>     1,
						  :tag_lines =>     1)
	 
		Template.create(  :name =>          'Our Family Cookbook 2', 
						  :template_type=>	2,
						  :has_image =>     0,
						  :tag_lines =>     1)
	
		Template.create(  :name =>          'Our Comunity Cookbook', 
						  :template_type=>	3,
						  :has_image =>     0,
						  :tag_lines =>     1)
	
		Template.create(  :name =>          'Our Cookbook', 
						  :template_type=>	4,
						  :has_image =>     0,
						  :tag_lines =>     2)
	
		Template.create(  :name =>          'Sharing Delicous Secrets', 
						  :template_type=>	5,
						  :has_image =>     0,
						  :tag_lines =>     2)
	
		Template.create(  :name =>          'Divine Cousine', 
						  :template_type=>	6,
						  :has_image =>     0,
						  :tag_lines =>     1)
	
		Template.create(  :name =>          'Insert Both Your Own Picture and Tagline', 
						  :template_type=>	7,
						  :has_image =>     1,
						  :tag_lines =>     4)
	
		Template.create(  :name =>          'The Do It All Cover', 
						  :template_type=>	8,
						  :has_image =>     1,
						  :tag_lines =>     1)
		puts "OK"
	
		print "# Adding Plans ..."
		Plan.create (	:title 				=> '1 Month Free Trial Membership', 
						:duration 			=> 1,
						:price	 			=> 0,
						:number_of_books 	=> 1)
	
		Plan.create (	:title 				=> '1 Month Membership', 
						:duration 			=> 1,
						:price	 			=> 14.95,
						:number_of_books 	=> 1)
	
		Plan.create (	:title 				=> '5 Month Membership', 
						:duration 			=> 5,
						:price	 			=> 49.95,
						:number_of_books 	=> 2)
	
		Plan.create (	:title 				=> '1 Year Membership', 
						:duration 			=> 12,
						:price	 			=> 79.95,
						:number_of_books 	=> 3)
	
		Plan.create (	:title 				=> 'Contributor Only', 
						:duration 			=> 0,
						:price	 			=> 0,
						:number_of_books 	=> 0,
						:purchaseable		=> 0)	
		puts "OK"
	
		puts "# ====================================================="
		puts "# Please execute \n# \trake comatose:data:import \n# to import comatose data"
		puts "# ====================================================="
		puts
	end

	def self.down
		drop_table :users
		drop_table :templates
		drop_table :sessions
		drop_table :sections
		drop_table :recipes
		drop_table :plans
		drop_table :cookbooks
		drop_table :comatose_pages
		drop_table :authorships
	end
end
