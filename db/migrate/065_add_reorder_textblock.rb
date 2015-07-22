class AddReorderTextblock < ActiveRecord::Migration
  def self.up
    Textblock.create(  
      :name         => "reorder", 
      :description  => "Order / Re-Order",
      :text         => "Here you can re-order any cookbooks you've ordered before.",
      :text_html    => "Here you can re-order any cookbooks you've ordered before."
    )
  rescue
    self.down
    raise
  end

  def self.down
    Textblock.find_by_name('reorder').destroy
  end
end
