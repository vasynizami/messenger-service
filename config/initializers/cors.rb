Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://messenger-service-production-4d91.up.railway.app'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end 