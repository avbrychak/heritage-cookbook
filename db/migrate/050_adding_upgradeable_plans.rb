class AddingUpgradeablePlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :upgradeable, :integer, :default => 0
    Plan.reset_column_information
    %w{8 9 10 11}.each do |plan_number|
      p = Plan.find plan_number
      p.upgradeable = 1
      p.save
    end
    p = Plan.find(11)
    p.purchaseable = 0
    p.save
  end

  def self.down
    remove_column :plans, :upgradeable
  end
end
