class Authorship < ActiveRecord::Base
  attr_accessible :user_id, :cookbook_id, :role, :user, :cookbook

  belongs_to :user
  belongs_to :cookbook
  
  validates_presence_of :user_id, :cookbook_id
  validates_uniqueness_of :user_id, :scope => :cookbook_id, :message => "is already on your list"
  
  ROLE = {
    :owner        => 1,
    :contributor  => 2
  }
end
