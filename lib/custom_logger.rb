module CustomLogger
	def unique_message_logger(message, file)
		f = File.open(Rails.root.join("log", "#{file}.log"), 'a')
		f.write "#{Time.now.to_s} - #{message}\n\n"
		f.close
	end
end