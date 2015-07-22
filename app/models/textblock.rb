class Textblock < ActiveRecord::Base

	before_save :convert_text_to_html

	attr_accessible :name, :description, :text, :text_html
  
  # -- Validations ----------------------------------------------------------
  
	validates_presence_of :name, :description
	validates_uniqueness_of :name
	
	
	# -- Callbacks ------------------------------------------------------------

  # -- Named Scopes ---------------------------------------------------------
  
  default_scope :order => 'description'

  # -- Instance Methods -----------------------------------------------------
  
  # Process the text, either the HTML or the TEXT version
	def get_text(type, data)
		return  case type
			  when :html; self.process(self.text_html, data)
				when :text; self.process(self.text, data)
				when :stripped_html; strip_html self.process(self.text_html, data)
				end
	end
	
	# For each item in the hash data, swap ::key:: with value
	def process(text, data)
		data.each{ |key, value| text.gsub!(Regexp.new('\(=' + key.to_s + '=\)'), value.to_s) }
		return text
	end
	
	def strip_html(text)
		text.gsub(/<\/?[^>]*>/, "").gsub(/[\n]{1,2}[\t]{0,1}/, "\n")
	end
	
	# -- Class Methods --------------------------------------------------------
	
	# Return the processed text
	def self.get(name, type = :html, data = {})
		return self.find_by_name(name).get_text(type, data).html_safe
	rescue
		return ''
	end

	private

	# Convert text to html using Textile
	def convert_text_to_html
		self.text_html = RedCloth.new(self.text).html_safe
	end
	
end