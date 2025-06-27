# filepath: /Users/andremendes/code/dehoullie/wanderplan/config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:5173', 'http://localhost:3000' # add your frontend dev URL(s)
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
