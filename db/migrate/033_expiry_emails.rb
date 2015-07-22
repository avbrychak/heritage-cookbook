class ExpiryEmails < ActiveRecord::Migration
  def self.up
		data = File.open('db/migrate/033_expiry_emails.yml', 'r').read
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