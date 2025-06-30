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
    budget      = Budget.find_by(level: params[:budget].to_i) || Budget.first
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

              ***IMPORTANT: You MUST generate exactly #{num_days} separate days in the itinerary, no more and no less.***

              Budget: #{budget.name}
              Preferences: #{preferences&.join(", ")}

              Each day is divided into Morning, Afternoon, and Evening.
              For each period, suggest exactly 3 different activities or places to visit, strictly matching only the user preferences.
              **Only suggest activities and places that match these preferences: #{preferences&.join(", ")}. Do NOT include any activities from other categories.**

              For each activity, include:
              - name (the place or activity)
              - category (MUST be one of: #{preferences&.join(", ")})
              - address
              - description (a short, one-sentence summary of the activity)

              Respond ONLY in this JSON format:
              {
                "days": [
                  {
                    "day": 1,
                    "morning": [...],
                    "afternoon": [...],
                    "evening": [...]
                  },
                  ...repeat for each day up to #{num_days}
                ]
              }
              ***Do not add any explanation or extra text, only the JSON.***
            PROMPT

    # Call ChatGPT API (OpenAI)
    gpt_response = call_chatgpt(prompt)

    puts "[GPT RESPONSE RAW]: #{gpt_response.inspect}"
    Rails.logger.info "[GPT RESPONSE RAW]: #{gpt_response.inspect}"

    # Compose the params hash for saving
    save_params = {
      country: cities.first ? cities.first['country'] : nil,
      city: cities.first ? cities.first['city'] : nil,
      preferences: preferences || [],
      budget: budget,
      max_days: num_days,
      gpt_response: gpt_response
    }

    # Save itinerary (optional: handle the result if needed)
    save_result = save_itinerary(save_params)

    if gpt_response.nil? || gpt_response.strip == ""
      render json: { gpt_response: nil, error: "GPT returned no response" }, status: :bad_gateway
    else
      render json: { gpt_response: gpt_response, save_result: save_result }, status: :ok
    end
  end

  def save_itinerary(params)
    puts "[TRIPS] Saving itinerary with params: #{params.inspect}"
    Rails.logger.info "[TRIPS] Saving itinerary with params: #{params.inspect}"
    # Save Country if it doesn't exist
    if Country.find_by(name: params[:country]).nil?
      country = Country.create(name: params[:country])
      puts "[TRIPS] Saved new country: #{country.name}"
    else
      country = Country.find_by(name: params[:country])
      puts "[TRIPS] Country already exists: #{country.name}"
    end

    # Save City if it doesn't exist. Every city belongs to a country and has an country_id FK
    if City.find_by(name: params[:city], country_id: country.id).nil?
      city = City.create(name: params[:city], country_id: country.id)
      puts "[TRIPS] Saved new city: #{city.name} in country #{country.name}"
    else
      city = City.find_by(name: params[:city], country_id: country.id)
      puts "[TRIPS] City already exists: #{city.name} in country #{country.name}"
    end
    # Save preference if it doesn't exist. city_id FK is used to link the preference to a city
    # budget_id FK is used to link the preference to a budget
    # max_days is the number of days the user wants to travel
    # slug is a unique identifier for the preference: ex: 3_berlin_museum-historical-restaurants_1 (first number is the days and second number is the budget level)
    preference_slug = "#{params[:max_days]}_#{city.name.downcase.gsub(" ", "-")}_#{params[:preferences].join("-")}_#{params[:budget].level}"
    if Preference.find_by(slug: preference_slug).nil?
      preference = Preference.create(
        city_id: city.id,
        budget_id: params[:budget].id,
        max_days: params[:max_days],
        slug: preference_slug
      )
      puts "[TRIPS] Saved new preference: #{preference.slug} for city #{city.name} with budget #{params[:budget].name}"
    else
      preference = Preference.find_by(slug: preference_slug)
      puts "[TRIPS] Preference already exists: #{preference.slug} for city #{city.name} with budget #{params[:budget].name}"
    end
    # Save Itinerary if it doesn't exist. Has: preference_id FK, title (ex: 5 days in Berlin, Germany - Museum, Historical Places, Restaurants)
    if Itinerary.find_by(preference_id: preference.id).nil?
      itinerary = Itinerary.create(
        preference_id: preference.id,
        title: "#{params[:max_days]} days in #{city.name}, #{country.name} - #{params[:preferences].join(", ")}"
      )
      puts "[TRIPS] Saved new itinerary: #{itinerary.title}"
    else
      itinerary = Itinerary.find_by(preference_id: preference.id)
      puts "[TRIPS] Itinerary already exists: #{itinerary.title}"
    end

    # Save Activities for each day in the itinerary. Has: itinerary_id FK, city_id FK, day number (1,2,3...), Part_of_day (morning, afternoon, evening), name, category, address, description
    gpt_response = params[:gpt_response]
    begin
      itinerary_data = JSON.parse(gpt_response)
    rescue JSON::ParserError => e
      Rails.logger.error "[TRIPS] JSON Parse Error: #{e.message}"
      puts "[TRIPS] JSON Parse Error: #{e.message}"
      return { error: "Invalid JSON format from GPT response" }
    end
    if itinerary_data["days"].blank?
      Rails.logger.error "[TRIPS] No days found in GPT response"
      puts "[TRIPS] No days found in GPT response"
      return { error: "No days found in GPT response" }
    end
    itinerary_data["days"].each do |day_data|
      day_number = day_data["day"]
      puts "[TRIPS] Processing day #{day_number} activities"
      Rails.logger.info "[TRIPS] Processing day #{day_number} activities"
      day_data["morning"].each do |activity|
        Activity.create(
          itinerary_id: itinerary.id,
          city_id: city.id,
          day: day_number,
          part_of_day: "morning",
          name: activity["name"],
          category_id: Category.find_by(slug: activity["category"].downcase.gsub(" ", "_")).id,
          address: activity["address"],
          description: activity["description"],
          map_url: activity["map_url"],
          priority: 1 # Default priority, can be adjusted later
        )
      end
      day_data["afternoon"].each do |activity|
        Activity.create(
          itinerary_id: itinerary.id,
          city_id: city.id,
          day: day_number,
          part_of_day: "afternoon",
          name: activity["name"],
          category_id: Category.find_by(slug: activity["category"].downcase.gsub(" ", "_")).id,
          address: activity["address"],
          description: activity["description"],
          map_url: activity["map_url"],
          priority: 2 # Default priority, can be adjusted later
        )
      end
      day_data["evening"].each do |activity|
        Activity.create(
          itinerary_id: itinerary.id,
          city_id: city.id,
          day: day_number,
          part_of_day: "evening",
          name: activity["name"],
          category_id: Category.find_by(slug: activity["category"].downcase.gsub(" ", "_")).id,
          address: activity["address"],
          description: activity["description"],
          map_url: activity["map_url"],
          priority: 3 # Default priority, can be adjusted later
        )
      end
    end
    puts "[TRIPS] Itinerary saved successfully with #{itinerary.activities.count} activities."
    Rails.logger.info "[TRIPS] Itinerary saved successfully with #{itinerary.activities.count} activities."
    { success: true, itinerary_id: itinerary.id, activities_count: itinerary.activities.count }
  end

  private

  def call_chatgpt(prompt)
    api_key = ENV["OPENAI_API_KEY"]
    url = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    body = {
      model: "gpt-4o",
      messages: [
        {role: "system", content: "You are a travel agent."},
        {role: "user", content: prompt}
      ],
      temperature: 0.7,
      response_format: { type: "json_object" }
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
