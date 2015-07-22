require "pdf_book/version"
require "pdf_book/document"
require "pdf_book/section"
require "open-uri"

module PDFBook

  ::SKIP_IMAGE_NOT_FOUND = !ENV['SKIP_IMAGE_NOT_FOUND'].nil?

  class Helpers
    
    # Raise an error if an image is not found
    def self.raise_error_if_image_not_found(uri)
      begin
        file = open(uri)
        file.close
        return false
      rescue OpenURI::HTTPError => e
        status = e.io.status[0]
        if SKIP_IMAGE_NOT_FOUND
          puts "HTTP Error #{status} - #{uri}"
          return true
        else
          raise "HTTP Error #{status} - #{uri}"
        end
      rescue Errno::ENOENT
        puts "File not found - #{uri}"
        return true
      end
    end
  end
end
