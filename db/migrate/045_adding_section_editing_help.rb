class AddingSectionEditingHelp < ActiveRecord::Migration
  def self.up
		data = File.open('db/migrate/045_adding_section_editing_help.yml', 'r').read
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
  end
end
