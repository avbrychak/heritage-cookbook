class Plan < ActiveRecord::Base
  has_many :users

  attr_accessible :title, :duration, :price, :number_of_books, :purchaseable, :upgradeable
  
  def price_in_dollars
    "$%.2f" % (self.price)
  end
  
  def Plan.available_signup_plans
    Plan.find(:all, :conditions => 'purchaseable=1').collect{|p| [p.title + '     ' + p.price_in_dollars, p.id]}
  end
  
  def self.all_plans
    self.find(:all).collect{|p| [p.title + '     ['+p.number_of_books.to_s+ ' books]', p.id]}
  end
  
  def is_free?
    self.price == 0
  end
  
  def self.available_upgrade_plans
    Plan.find(:all, :conditions=>'upgradeable=1').collect{|p| [p.title + '     ' + p.price_in_dollars, p.id]}
  end

  def self.gift_card_plans
    Plan.find(:all, :conditions=>"purchaseable='1' AND id != 1").collect{|p| [p.title + '     ' + p.price_in_dollars, p.id]}
  end
  
  def self.plans_for_select
    all.collect{|p| [p.title, p.id]}
  end
  
  def price_in_cents
    (self.price*100).round
  end
  
end
