class TemplateConfigurationError < StandardError
end

class TemplateConfiguration

  attr_reader :properties

  TEMPLATES_FOLDER = Rails.root.join('app', 'book_templates')

  def initialize(id, options = {})
    @id = id
    @template_folder = options[:template_folder] || TEMPLATES_FOLDER
    @properties = read_properties
  end

  def method_missing(sym, *args, &block)
    method_name = unbooleanize_method_name sym.to_s
    if properties.has_key?(method_name) 
      ask_for_boolean?(sym.to_s) ? booleanize(properties[method_name]) : properties[method_name]
    else 
      super
    end
  end

  def respond_to_missing?(sym, include_private = false)
    properties.has_key?(unbooleanize_method_name(sym.to_s)) || super
  end

  private

  def ask_for_boolean?(method_name)
    method_name.end_with? "?"
  end

  def unbooleanize_method_name(method_name)
    method_name.chop! if method_name.end_with? "?"
    method_name
  end

  def booleanize(value)
    case value
    when 1
      true
    when 0
      false
    when "true"
      true
    when "false"
      false
    when true
      true
    when false
      false
    else
      nil
    end
  end

  def read_properties
    config_file = "#{@template_folder}/#{@id}/config.yml"
    raise TemplateConfigurationError, "Cannot load the template config file - #{config_file}" unless File.exist? config_file
    YAML.load_file config_file
  end
end