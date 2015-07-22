class RenameContributorPlan < ActiveRecord::Migration
  def self.up
    plan = Plan.find_by_title('Contributor Only OLD')
    plan.update_attribute(:title, 'Contributor Only')
  end

  def self.down
    plan = Plan.find_by_title('Contributor Only')
    plan.update_attribute(:title, 'Contributor Only OLD')
  end
end
