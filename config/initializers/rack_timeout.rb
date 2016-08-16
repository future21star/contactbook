Rails.application.middleware.use Rack::Timeout
Rack::Timeout.timeout = 12000  # seconds
