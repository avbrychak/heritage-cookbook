# Manage emails for Wordpress API
class WordpressMailer < ActionMailer::Base

  # Send a recipe
  def recipe(options={})
    recipient = options[:to] || WORDPRESS_API_EMAIL
    @title = options[:title]
    @section = options[:section]
    @ingredients = options[:ingredients]
    @instructions = options[:instructions]
    @author = options[:author]
    @author_display_name = options[:author_display_name]
    @contributor_display_name = options[:contributor_display_name]
    @contributor_email = options[:contributor_email]
    @author_city = options[:author_city]
    @author_state = options[:author_state]
    @author_email = options[:author_email]
    @tags = options[:tags]

    mail to: recipient,
      from: CONTACT_EMAIL,
      subject: "[#{@section.capitalize}] #{@title.capitalize}"
  end
end
