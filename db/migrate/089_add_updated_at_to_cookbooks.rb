class AddUpdatedAtToCookbooks < ActiveRecord::Migration
  def self.up
    add_column :cookbooks, :updated_at, :datetime
  end

  def self.down
    remove_column :cookbooks, :updated_at
  end
end
