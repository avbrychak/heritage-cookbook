if ENV["OINK_MEMORY_LOG"] == "true"
  Rails.application.middleware.use Oink::Middleware
end