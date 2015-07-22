module Comatose
  class Page < ActiveRecord::Base
    set_table_name 'comatose_pages'
  end
end

class UpgradeToComatoseV06 < ActiveRecord::Migration

  # Upgrades schema from version 0.4 to version 0.6 
  def self.up
    add_column :comatose_pages, "created_on", :datetime
    puts "Setting created_on times..."
    execute("UPDATE comatose_pages SET created_on=updated_on")
    # Comatose::Page.find(:all).each do |page|
    #   page.update_attribute(:created_on, page.updated_on || Time.now)
    # end
  rescue
    self.down
    raise
  end

  # Downgrades schema from version 0.6 to version 0.4
  def self.down
    remove_column :comatose_pages, "created_on"
  end

end
