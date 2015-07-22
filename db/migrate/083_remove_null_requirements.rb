class RemoveNullRequirements < ActiveRecord::Migration
  def self.up
    change_column :cookbooks, :intro_text, :text, :null=> true
  end

  def self.down
    change_column :cookbooks, :story, :string, :null=> false
  end
end
