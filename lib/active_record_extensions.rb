# Extend ActiveRecord::Base functionnality
module ActiveRecordExtensions
  
  # Like `update_attributes` but save the correct fields in the database
  def update_attributes_individually(attributes)
    validated_attributes = {}
    if !update_attributes(attributes)
      attributes.each do |attr_name, attr_value|
        if self.errors[attr_name].blank?
          validated_attributes[attr_name] = attr_value
        end
      end
    end
    
    # Save each validated attribute in the database without altering the current object
    if validated_attributes.any?
      clone = self.class.send :find, self.id
      attributes.each do |attr_name, attr_value|
        if validated_attributes[attr_name]
          clone.send "#{attr_name}=", attr_value
        end
      end
      clone.save
    end

    self.errors.empty?
  end

  # Implement warnings for models
  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end
end