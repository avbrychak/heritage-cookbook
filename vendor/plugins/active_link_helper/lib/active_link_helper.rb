module ActiveLinkHelper
  def active_link(label, link, regex = nil, options = { })
    options[:class] ||= ''
    options[:class] += active_class(link, regex)
    link_to(content_tag(:span, label), link, options)
  end
  
  def active_class(link, regex = nil)
    case (regex)
    when :self
      regex = /^#{Regexp.escape(link)}(\/?.*)?/
    when :self_only
      regex = /^#{Regexp.escape(link)}\/?(\?.*)?$/
    end
  
    if (regex and request.url.match(regex))
      return 'active' 
    else
      return ''
    end
  end
end