class BookBinding < ActiveRecord::Base
  attr_accessible :max_number_of_pages, :name

  has_many :cookbooks

  # Return the binding name symbol
  def to_sym
  	name.downcase.gsub(/\s+/, "_").to_sym
  end

  def to_s
  	name
  end
end
