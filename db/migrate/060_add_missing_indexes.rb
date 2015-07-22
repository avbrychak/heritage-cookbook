class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    remove_index :authorships, :user_id
    remove_index :authorships, :cookbook_id
    add_index :authorships, [:user_id, :cookbook_id], :name => 'authorships_user_id_cookbook_id_index'
    add_index :authorships, [:cookbook_id, :user_id], :name => 'authorships_cookbook_id_user_id_index'
    
    add_index :users, [:plan_id, :created_on], :name => 'users_plan_id_created_on_index'
    add_index :users, [:created_on, :plan_id], :name => 'users_created_on_plan_id_index'
    
    remove_index :recipes, :user_id
    remove_index :recipes, :section_id
    add_index :recipes, [:user_id, :section_id], :name => 'recipes_user_id_section_id_index'
    add_index :recipes, [:section_id, :user_id], :name => 'recipes_section_id_user_id_index'

    remove_index :sections, :cookbook_id
    add_index :sections, [:cookbook_id, :section_image_id], :name => 'sections_cookbook_id_section_image_id_index'
    add_index :sections, [:section_image_id, :cookbook_id], :name => 'sections_section_image_id_cookbook_id_index'
    
    add_index :taggings, [:tag_id, :taggable_id], :name => 'taggings_tag_id_taggable_id_index'
    add_index :taggings, [:taggable_id, :tag_id], :name => 'taggings_taggable_id_tag_id_index'
  rescue
    self.down
    raise
  end

  def self.down
    remove_index :authorships, :name => 'authorships_user_id_cookbook_id_index'
    remove_index :authorships, :name => 'authorships_cookbook_id_user_id_index'
    add_index :authorships, :user_id
    add_index :authorships, :cookbook_id

    remove_index :users, :name => 'users_plan_id_created_on_index'
    remove_index :users, :name => 'users_created_on_plan_id_index'

    remove_index :recipes, :name => 'recipes_user_id_section_id_index'
    remove_index :recipes, :name => 'recipes_section_id_user_id_index'
    add_index :recipes, :user_id
    add_index :recipes, :section_id

    remove_index :sections, :name => 'sections_cookbook_id_section_image_id_index'
    remove_index :sections, :name => 'sections_section_image_id_cookbook_id_index'
    add_index :sections, :cookbook_id

    remove_index :taggings, :name => 'taggings_tag_id_taggable_id_index'
    remove_index :taggings, :name => 'taggings_taggable_id_tag_id_index'
  end
end
