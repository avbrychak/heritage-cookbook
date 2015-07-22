# Proxy missing methods to a TemplateConfiguration instance if it 
# respond to. Used to store all template settings used by the PDF 
# engine in a config file instead of the database.
module TemplateConfigurationLoader

	def method_missing(sym, *args, &block)
    if config.respond_to? sym
      config.send sym
    else
      super
    end
  end

  def respond_to_missing?(sym, include_private = false)
    config.respond_to? sym || super
  end

  private

  def config
		@config ||= TemplateConfiguration.new template_type
	end
end