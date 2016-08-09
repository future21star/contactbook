Rails.application.middleware.use Rack::Timeout
Rack::Timeout.timeout = 1200  # seconds
