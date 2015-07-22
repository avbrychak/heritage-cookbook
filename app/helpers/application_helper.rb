module ApplicationHelper

  # Display remaining days for the current account membership
  def how_many_days_left?
    days = 0
    if current_user.expiry_date
      cal = (current_user.expiry_date - Date.today).to_i
      days = cal if cal >= 0
    end
    return days
  end

  # Return the classes name for the given step list item.
  def classes_for_design_step(step_name)
    classes = []
    design_steps = [:pick_a_design, :personalize_design, :introduction]
    design_steps_actions = {
      pick_a_design:      "templates#index",
      personalize_design: "cookbooks#edit",
      introduction:       "cookbooks#edit_introduction"
    }
    current_action = "#{controller.controller_name}##{controller.action_name}"

    # Current class
    classes << "current" if current_action == design_steps_actions[step_name]

    # Done class
    case step_name
    when :pick_a_design
      classes << "done" if current_cookbook.book_binding && current_cookbook.template
    when :personalize_design
      classes << "done" if (current_cookbook.template && current_cookbook.template.tag_lines > 0 && current_cookbook.tag_line_1 && !current_cookbook.tag_line_1.empty?) || 
        current_cookbook.user_cover_image? || 
        current_cookbook.user_image?
    when :introduction
      classes << "done" if current_cookbook.intro_type == 2 || (current_cookbook.intro_text && !current_cookbook.intro_text.empty?  )
    end

    return classes.join(" ")
  end


  # Return the current cookbook creation step.
  def current_cookbook_step
    return @current_step if @current_step
    view = "#{controller.controller_name}##{controller.action_name}"
    cookbook_steps = {
      "templates#index"              => :design,
      "cookbooks#edit"               => :design,
      "cookbooks#edit_introduction"  => :design,

      "contributors#index"           => :contributors,

      "recipes#new"                  => :recipes,
      "recipes#edit"                 => :recipes,
      "sections#new"                 => :recipes,
      "sections#index"               => :recipes,
      "sections#edit"                => :recipes,
      "extra_pages#new"              => :recipes,
      "extra_pages#edit"             => :recipes,
      "cookbooks#check_price"        => :recipes,

      "orders#new"                   => :preview_and_order,
      "orders#reorder"               => :preview_and_order,
      "orders#guest"                 => :preview_and_order,
      "orders#edit_customer_details" => :preview_and_order,
      "orders#confirm"               => :preview_and_order,
      "orders#ask_price_quote"       => :preview_and_order
    }
    @current_step = cookbook_steps[view]
  end

  # Output a link opening a modal for cookbook previews
  def link_to_preview(text, preview_url, options={})
    modal_tag text, 
      render("previews/modal_preview_status", title: text.capitalize), 
      class: "preview-link #{options[:class]}", 
      data: {'preview-url' => preview_url},
      title: "Preview"
  end

  # Ouput javascript to resize the specified modal if exist.
  def resize_modal(modal_selector)
    output = "// Resize the modal if exist\n"
    output += "var $modal = #{modal_selector};\n"
    output += "var modal_width = $modal.outerWidth();\n"
    output += "$modal.css('margin-left', -(modal_width/2) + 'px');"
    return output.html_safe
  end

  # Display a link opening a modal view.
  def modal_tag(text, html, options={})
    id = options[:id] || rand(36**7...36**8).to_s(36)
    data = (options[:data]) ? options[:data].keys.map{|key| "data-#{key}='#{options[:data][key]}'"}.join(" ") : ""
    link = "<a href='##{id}' alt='modal #{id}' class='modal-link #{options[:class]}' title='#{options[:title] || text}' #{data}>#{text}</a>"
    modal = "<div class='modal hidden' id='#{id}'>#{html}</div>"
    output = link + modal
    return output.html_safe
  end

  # Display a modal content
  def modal(id, html)
    modal = "<div class='modal hidden' id='#{id}'>#{html}</div>"
    output = modal
    return output.html_safe
  end

  # Display a link to a modal
  def link_to_modal(text, id, options={})
    link = "<a href='##{id}' alt='modal #{id}' class='modal-link #{options[:class]}' title='#{text}'>#{text}</a>"
    return link.html_safe
  end

  # Display error messages for an object instance.
  def errors_for(instance)
    output = '<div class="form-errors">'
    output += '<p class="note">Uh oh! There are some errors on this form. Please fix them and submit it again.</p>'
    output += '<ul>'
    messages = []
    instance.errors.each do |field, message|
      if !messages.include? message
        messages << message
        output += "<li class='note #{field}'>#{message}</li>"
      end
    end
    output += '</ul>'
    output += '</div>'
    return output.html_safe
  end

  # Display a list of contributors by their name linked to their email address, separated by coma.
  def contributors_list(users)
    users.map {|user| mail_to user.email, user.name }.join(', ').html_safe
  end

  # -----------

  # Form creation helper
  #  takes following element_params:
  #  :value -> value of the form element
  #  :label -> left hand-side label
  #  :desc -> description of the element (if label is simply not enough)
  def form_element (type, name, method, htmltag_params = {}, element_params = {})
    output = "<li>"    
    case type
      
      when 'text'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << text_field(name, method, htmltag_params)
        output << element_params[:suffix] unless !element_params[:suffix]
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'password'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << password_field(name, method, htmltag_params)
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'hidden'
        output = "<li class=\"hidden\">"
        output << hidden_field(name, method, htmltag_params)        
      
      when 'text_area'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << text_area(name, method, htmltag_params)
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'select'
        select_options = element_params[:select_options] || {}
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << select(name, method, element_params[:collection], select_options, htmltag_params) 
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      
      # this is not needed the moment I figure out how to access COUNTRIES constant
      when 'country_select'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << country_select(name, method, element_params[:priority_countries], element_params[:select_options] = {}, htmltag_params)
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'radio_button'
        output << "<label class=\"rightside\" for=\"#{name}_#{method}_#{element_params[:value]}\">#{element_params[:label]}</label>"
        htmltag_params["class"] = "checkbox"
        output << radio_button(name, method, element_params[:value], htmltag_params)
        output << "<div class=\"desc #{element_params[:desc_class]}\">#{element_params[:desc]}</div>" if element_params[:desc]

      when 'check_box'        
        output << "<label class=\"rightside\" for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        htmltag_params["class"] = "checkbox"
        element_params[:value] = '1' unless element_params[:value]
        element_params[:unchecked_value] = '0' unless element_params[:unchecked_value]
        output << check_box(name, method, htmltag_params, element_params[:value].to_s, element_params[:unchecked_value].to_s)
        output << "<div class=\"desc #{element_params[:desc_class]}\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'file'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << file_field(name, method, htmltag_params)
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
        
      when 'file_tag'
        output << "<label for=\"#{name}\">#{element_params[:label]}</label>"
        output << file_field_tag(name, htmltag_params)
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
        
      when 'file_column_field'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << file_column_field(name, method, htmltag_params)
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'image'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << image_tag(url_for_file_column(name, method, htmltag_params[:version]))
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]

      when 'regular_image'
        output << "<label for=\"#{name}_#{method}\">#{element_params[:label]}</label>"
        output << image_tag(htmltag_params[:src])
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]

      when 'submit'
        htmltag_params[:class] = "submit" unless htmltag_params[:class] != nil
        htmltag_params[:disable_with] = "Please Wait..."
        output << submit_tag(element_params[:value], htmltag_params)
        output << " or " << (link_to element_params[:cancel], :controller => element_params[:controller], :action => element_params[:action]) if element_params[:cancel] && element_params[:controller] && element_params[:action]          
        output << "<div class=\"desc\">#{element_params[:desc]}</div>" if element_params[:desc]
      
      when 'image_submit'
        htmltag_params[:class] = "submit" unless htmltag_params[:class] != nil
        output = "<li class=\"rightalign\">"
        output << image_submit_tag(element_params[:source], htmltag_params)
        output << "<div class=\"desc\"><#{element_params[:desc]}</div>" if element_params[:desc]

      when 'comment'
        output = "<li><div class=\"msg\">#{element_params[:msg]}</div>" if element_params[:msg]
    end
    
    output << "</li>"
    output.html_safe
  end
  
  #  form block (basically a fieldset)
  #  takes following parameters
  #  : class
  #  : id   - applies to the list
  #  : style - because scriptaculous wants inline style definitions. grr. applies to the list
  #  : legend
  #  : label - not an actual label, but a <div>
  def start_form_block (params = {})
    output = ""
    output << "<li><div class=\"label\">#{params[:label]}</div>" if params[:label]
    
    if params[:class]
      output << tag('fieldset', {:class => params[:class]}, true)
    else 
      output << tag('fieldset', {}, true)
    end
    
    output << content_tag('legend', params[:legend]) if params[:legend]
    
    output << "<ol"
    output << " style=\"#{params[:style]}\" " if params[:style]
    output << " id=\"#{params[:id]}\"" if params[:id]
    output << ">"
    output.html_safe
  end  
  
  # closing the form block
  def end_form_block
    "</ol></fieldset>".html_safe
  end

  # closing form block and li tag as it's still inside another form block
  def end_nested_form_block
    "</ol></fieldset></li>".html_safe
  end

  # error_messages_for redefinition
  def error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    @object = object
    if object && !object.errors.empty?    
      output = "<div class=\"formError\"><div class=\"corner\">"
      output << "Uh oh! There are some errors on this form. Please fix them and submit it again."
      output << "<ul>"
      object.errors.each { |key, error|
        output << "<li>#{key.to_s.capitalize.gsub('_', ' ')}: #{error}</li>"
      }
      output << "<li></li>"
      output << "</ul></div></div>"
      output.html_safe
    end
  end


  # Displays formatted help
  # Help partials should be located at /views/help/
  def page_help(partial, start_opened=true)    
    output = '<div id="page_help">'   
    output << '<div id="page_help_title">'
    output << '<div class="helppot">'
    output << link_to_function(image_tag("helppot.jpg"), 
                                update_page { |page| 
                                page.visual_effect :toggle_blind, 'page_help_content', :duration => 0.5
                                page.toggle 'help_view', 'help_hide'
                                }
                              )
    output << '</div>'
    if start_opened
      view_instructions = '<span id="help_view" style="display:none">view</span><span id="help_hide">hide</span>'
    else
      view_instructions = '<span id="help_view">view</span><span id="help_hide" style="display:none">hide</span>'
    end
   
    output << link_to_function("Help / Instructions (click to view)", 
                                update_page{ |page|
                                page.visual_effect :toggle_blind, "page_help_content", :duration => 0.5
                                page.toggle 'help_view', 'help_hide'
                                }
                              )
    output << '<div class="floatclear"></div>'
    
    output << '</div>'
    if start_opened
      output << '<div id="page_help_content">'
    else
      output << '<div id="page_help_content" style="display:none">'
    end  
    output << Textblock.get(partial)
    output << "</div></div>"
    output.html_safe
  end
  
  def nl2br(string)
    if !string.blank?
      string.gsub("\n\r","<br>").gsub("\r", "").gsub("\n", "<br />").html_safe
    end
  end
  
  def escape_single_quotes(string)
    string.gsub(/[']/, '\\\\\'').html_safe
  end
  
  # Display an image in the help section
  def help_image_tag(image)
    output = '<div class="screenshot">'
    output << image_tag(image)
    output << '</div>'
    output.html_safe
  end
  

  # Javascript helper to raise and hide 2 objects
  def blind_down_up(down_name, up_name)
    page.visual_effect :blind_down, down_name, {:duration => 0.5, :queue => {:scope => 'whatever', :limit => 2}} 
    page.visual_effect :blind_up, up_name, {:duration => 0.5, :queue => {:scope => 'whatever', :limit => 2}}
    page.visual_effect :highlight, down_name, :duration => 2
  end
  

  def clean_params
    passable_params = HashWithIndifferentAccess.new(params)
    passable_params.delete(:action)
    passable_params.delete(:controller)
    passable_params.delete(:id)
    passable_params
  end  
  
  # Adding this for performance reasons, because owners were being loaded all the time
  def owners_cache(user_id)
    @owners = Hash.new if @owners.nil?
    @owners[user_id] = User.find(user_id) unless @owners.include?(user_id)
    @owner = @owners[user_id]
  end
  
  def expiry_time(date)
    expiry_days = (date - Date.today).to_i
    case
    when expiry_days > 0
      "expires in #{pluralize expiry_days, 'day'}"
    when expiry_days < 0
      "expired #{pluralize -expiry_days, 'day'} ago"
    else
      'expired today'
    end
  end

  def ordinal_suffix(number)
    last_2_digits = number.to_s[-2..-1].to_i
    sufix = 'th'
    
    if last_2_digits < 10 || last_2_digits > 20
      sufix = case number.to_s.last
      when '1'
        'st'
      when '2'
        'nd'
      when '3'
        'rd'
      else 
        'th'
      end
    end
    "#{number}#{sufix}"
  end

  def recipe_image_icon(recipe)
    icon = ''
    if recipe.photo?
      icon += 'picture'
      icon += '_warning' if recipe.small_photo?
      icon += '_grayscale' if recipe.grayscale?
    end
    icon
  end
end
