Rails.application.middleware.use Rack::Timeout
Rack::Timeout.timeout = 12000  # seconds
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 12000