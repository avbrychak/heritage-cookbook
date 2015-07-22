# Class imported from an old "act_as_taggable" plugin.
class Tagging < ActiveRecord::Base

  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  attr_accessible :taggable

  def self.tagged_class(taggable)
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, taggable.class).to_s
  end
  
  def self.find_taggable(tagged_class, tagged_id)
    tagged_class.constantize.find(tagged_id)
  end
end