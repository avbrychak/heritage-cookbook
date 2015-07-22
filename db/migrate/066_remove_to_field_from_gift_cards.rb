class RemoveToFieldFromGiftCards < ActiveRecord::Migration
  def self.up
    remove_column :gift_cards, :to
    add_column :gift_cards, :give_on, :datetime
    add_index :gift_cards, :give_on
  end

  def self.down
    add_column :gift_cards, :to, :string
    remove_column :gift_cards, :give_on  end
end
