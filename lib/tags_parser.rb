require 'csv'

# Used to parcour a csv of tags and find matches for given words
class TagsParser
  attr_reader :tags

  # Load tags from a CSV file (tags must be in the first column) 
  # and order them by length
  def initialize(csv)
    @tags = []
    CSV.foreach(csv) do |row|
      @tags << row[0]
    end
    @tags.sort!{|x, y| y.length <=> x.length}
  end

  # Match given strings with tags extracted from the CSV file
  # Return an array of tag
  def match(*strings)
    result = []
    @tags.each do |tag|
      strings.each do |string|
        if string.downcase =~ /#{tag.downcase}/
          strings.delete string
          result << tag
          break
        end
      end
    end
    return result
  end
end