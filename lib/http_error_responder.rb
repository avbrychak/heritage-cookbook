module HttpErrorResponder
protected
  def respond_with_error_page(code, title)
    render(:file => Rails.root.join("public", "#{code}.html"), :layout => "application", :status => code.to_i)
    # NOTE: Return false so that the before_filter processing chain halts
    false
  end

  def respond_with_404
    respond_with_error_page(404, "Page Not Found")
  end

  def respond_with_403
    respond_with_error_page(403, "Access Denied")
  end
  
  def respond_with_422
    respond_with_error_page(422, "Change Rejected")
  end
  
  def respond_with_500
    respond_with_error_page(500, "Server Error")
  end
end
