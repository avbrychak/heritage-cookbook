class RenameUpdatedAtToUpdatedOn < ActiveRecord::Migration
  def self.up
    rename_column :cookbooks, :updated_at, :updated_on
  end

  def self.down
    rename_column :cookbooks, :updated_on, :updated_at
  end
end
