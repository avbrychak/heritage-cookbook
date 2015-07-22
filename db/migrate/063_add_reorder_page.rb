class AddReorderPage < ActiveRecord::Migration
  def self.up
    ComatosePage.create!(
      :parent_id => 1,
      :full_path => 'reorder',
      :title => 'Heritagecookbook.com - Reorder',
      :slug => 'reorder',
      :body => %{<h1>Reorder</h1>}
    )
  end

  def self.down
    if @reorder_page = ComatosePage.find_by_slug('reorder')
      @reorder_page.destroy
    end
  end
end
