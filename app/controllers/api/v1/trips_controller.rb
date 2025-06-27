require "net/http"
require "uri"
require "json"

class Api::V1::TripsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/v1/trips/plan
  def plan
    # Receive params from frontend
    cities      = params[:cities] || []
    start_date  = params[:start_date]
    end_date    = params[:end_date]
    budget      = params[:budget]
    preferences = params[:preferences]

    require 'date'

      start_date = params[:start_date]
      end_date   = params[:end_date]

      num_days = 1
      if start_date.present? && end_date.present?
        begin
          d1 = Date.parse(start_date)
          d2 = Date.parse(end_date)
          num_days = (d2 - d1).to_i + 1  # Add 1 to include both start and end dates
          num_days = 1 if num_days < 1   # Fallback in case of wrong order
        rescue ArgumentError => e
          Rails.logger.error "[TRIPS#plan] Invalid dates: #{start_date} #{end_date} (#{e.message})"
          num_days = 1
        end
      end



    # Format cities for the prompt
    cities_str = cities.map { |c| "#{c['city']}, #{c['country']}" }.join("; ")

    # Compose prompt for ChatGPT
    prompt = <<~PROMPT
      Generate a detailed travel itinerary for the following trip:
      Destinations: #{cities_str}
     Number of days: #{num_days}
      Budget: #{budget}
      Preferences: #{preferences&.join(", ")}

      Each day is divided into Morning, Afternoon, and Evening.
      For each period, suggest exactly 3 different activities or places to visit.
      For each activity, include:
      - name (the place or activity)
      - category (one of: Museum, Historical Places, Restaurants, Religious Site, Theme Park, Shopping and Commercial Areas, Natural points of interest)
      - address
      - description (a short, one-sentence summary of the activity)

      Respond ONLY in this JSON format:
      {
        "days": [
          {
            "day": 1,
            "morning": [
              { "name": "...", "category": "...", "address": "...", "description": "..." },
              { "name": "...", "category": "...", "address": "...", "description": "..." },
              { "name": "...", "category": "...", "address": "...", "description": "..." }
            ],
            "afternoon": [
              { "name": "...", "category": "...", "address": "...", "description": "..." },
              { "name": "...", "category": "...", "address": "...", "description": "..." },
              { "name": "...", "category": "...", "address": "...", "description": "..." }
            ],
            "evening": [
              { "name": "...", "category": "...", "address": "...", "description": "..." },
              { "name": "...", "category": "...", "address": "...", "description": "..." },
              { "name": "...", "category": "...", "address": "...", "description": "..." }
            ]
          }
          // ... repeat for each day
        ]
      }
      Do not add any explanation or extra text, only the JSON.
    PROMPT

    # Call ChatGPT API (OpenAI)
    gpt_response = call_chatgpt(prompt)

    puts "[GPT RESPONSE RAW]: #{gpt_response.inspect}"
    Rails.logger.info "[GPT RESPONSE RAW]: #{gpt_response.inspect}"

    if gpt_response.nil? || gpt_response.strip == ""
      render json: { gpt_response: nil, error: "GPT returned no response" }, status: :bad_gateway
    else
      render json: { gpt_response: gpt_response }, status: :ok
    end
  end

  def save_itinerary
    # Not implemented here, left for your next step!
  end

  private

  def call_chatgpt(prompt)
    api_key = ENV["OPENAI_API_KEY"]
    url = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    body = {
      model: "gpt-3.5-turbo-0125",
      messages: [
        {role: "system", content: "You are a travel agent."},
        {role: "user", content: prompt}
      ],
      temperature: 0.7
    }

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    request.body = body.to_json

    response = http.request(request)
    puts "[GPT HTTP RESPONSE BODY]: #{response.body}"
    Rails.logger.info "[GPT HTTP RESPONSE BODY]: #{response.body}"

    begin
      json = JSON.parse(response.body)
    rescue JSON::ParserError => e
      Rails.logger.error "[GPT] JSON Parse Error: #{e.message}"
      puts "[GPT] JSON Parse Error: #{e.message}"
      return nil
    end

    if response.code != "200"
      Rails.logger.error "[GPT ERROR] HTTP Status: #{response.code} - #{response.body}"
      puts "[GPT ERROR] HTTP Status: #{response.code} - #{response.body}"
      return nil
    end

    # Extract the actual text response from OpenAI
    content = json.dig("choices", 0, "message", "content") rescue nil
    content
  end
end
