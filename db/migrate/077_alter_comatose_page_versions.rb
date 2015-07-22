class AlterComatosePageVersions < ActiveRecord::Migration
  def self.up
    rename_table :page_versions, :comatose_page_versions
    rename_column :comatose_page_versions, :page_id, :comatose_page_id
    execute("UPDATE comatose_pages SET filter_type='[No Filter]' WHERE filter_type = 'None'")
  rescue
    self.down
    rake
  end

  def self.down
    execute("UPDATE comatose_pages SET filter_type='None' WHERE filter_type = '[No Filter]'")
    rename_column :comatose_page_versions, :comatose_page_id, :page_id
    rename_table :comatose_page_versions, :page_versions
  end
end
