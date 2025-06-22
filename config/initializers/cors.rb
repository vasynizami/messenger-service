Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://messenger-app-production.up.railway.app', 'https://messenger-service-production-4d91.up.railway.app', 'http://localhost:4200'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end 