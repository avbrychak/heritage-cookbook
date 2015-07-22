module AdminHelper
	
	def sort_link(text, param)
		key = param
		key += "_reverse" if params[:sort] == param

		html_class = 'sort_down' if params[:sort] == param
	  	html_class = 'sort_up' if params[:sort] == param + "_reverse"

		link_to(text, {:action => 'users', :params => params.merge(:sort => key)}, {:class => "sorter #{html_class}"})
	end
	
	def to_yes_no(attribute_value)
    attribute_value ? "Yes" : "No"
  end

  def pagination_text(search, collection)
    start = 1 + (search.per_page * search.prev_page)
    "Showing users: " + start.to_s + " - " + (start + collection.length - 1).to_s + " of " + search.count.to_s + " total"
  end
  
end
