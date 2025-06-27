# app/controllers/api/v1/places_controller.rb
class Api::V1::PlacesController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  def index
    query = params[:q].to_s.strip
    return render json: [] if query.blank?

    url = URI("https://maps.googleapis.com/maps/api/place/autocomplete/json")
    url.query = URI.encode_www_form({
      input: query,
      types: "(cities)",
      key: ENV.fetch("GOOGLE_PLACES_API_KEY")
    })
    resp = Net::HTTP.get_response(url)
    data = JSON.parse(resp.body)
    predictions = data.fetch("predictions", [])

    suggestions = predictions.first(3).map do |p|
      # Use description or terms to extract city and country
      terms = p["terms"] || []
      city = terms[0]&.dig("value") || ""
      country = terms[-1]&.dig("value") || ""
      {
        id: p["place_id"],
        city: city,
        country: country,
        label: "#{city}, #{country}"
      }
    end

    render json: suggestions
  rescue => e
    puts "[PLACES API ERROR]: #{e}"
    render json: [], status: :internal_server_error
  end
end
