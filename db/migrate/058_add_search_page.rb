class AddSearchPage < ActiveRecord::Migration
  def self.up
    ComatosePage.create!(
      :parent_id => 1,
      :full_path => 'search',
      :title => 'Search',
      :slug => 'search',
      :body => %{<h1>Search</h1>
<script src="http://www.google.com/jsapi?key=ABQIAAAAe9jYbD9oGRogeRVaA19QAxT1JuWAY3DKio6-DtlyWkm8ngyDAxTu8lyKvKoHl4xhQEiwDrv5pCD79w" type="text/javascript"></script>
      <script src="javascripts/google_search.js" language="Javascript" type="text/javascript"</script>
      </script><div id="searchcontrol">Loading</div>
}
      
    )
  end

  def self.down
    if @search_page = ComatosePage.find_by_slug('search')
      @search_page.destroy
    end
  end
end
