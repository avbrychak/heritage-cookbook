class AdminTextblocks < ActiveRecord::Migration	
	def self.up
		create_table "textblocks" do |t|
			t.column "id", :integer
			t.column "name", :string
			t.column "description", :string
			t.column "text", :text
			t.column "text_html", :text
		end

		data = File.open('db/migrate/020_textblocks_data.yml', 'r').read
		blocks = YAML.load(data)
		blocks.each { |block|
			Textblock.create(	:name 			=> block.ivars['attributes']['name'], 
								:description 	=> block.ivars['attributes']['description'],
								:text			=> block.ivars['attributes']['text'],
								:text_html		=> block.ivars['attributes']['text_html']
							)
	    }
	end
	
	def self.down
		drop_table :textblocks
	end
end