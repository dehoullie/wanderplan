require 'open-uri'

class Api::V1::ItinerariesController < ApplicationController
  def show
    @itinerary = Itinerary.includes(
      preference: [
        :budget,
        { city: :country }
      ],
      activities: [:category]
    ).find_by(id: params[:id])

    if @itinerary
      # Gather activities and their categories
      activities = @itinerary.activities.order(:day, :part_of_day, :id).map do |a|
        {
          id: a.id,
          day: a.day,
          part_of_day: a.part_of_day,
          name: a.name,
          description: a.description,
          address: a.address,
          category_name: a.category&.name,
          category_slug: a.category&.slug
        }
      end

      # For the summary badges, grab unique category names
      summary_categories = activities.map { |a| a[:category_name] }.uniq.compact

      city = @itinerary.preference.city
      city_name = city&.name
      country_name = city&.country&.name
      city_image_url = (city_name.present? && country_name.present?) ? save_city_image(city_name, country_name) : nil

      render json: {
        id: @itinerary.id,
        title: @itinerary.title,
        preference: {
          max_days: @itinerary.preference.max_days,
          budget: {
            name: @itinerary.preference.budget&.name
          },
          city: {
            name: @itinerary.preference.city&.name,
            country: {
              name: @itinerary.preference.city&.country&.name
            },
            image_url: city_image_url
          }
        },
        summary_categories: summary_categories,
        activities: activities
      }
    else
      render json: { error: 'Itinerary not found' }, status: :not_found
    end
  end

  def find_existing
    city = params[:city]
    preferences = (params[:preferences] || '').split(',')
    budget = params[:budget].to_i
    max_days = params[:max_days].to_i

    itinerary = Itinerary
      .joins(preference: [:city, :budget])
      .where('cities.name = ?', city)
      .where('preferences.max_days = ?', max_days)
      .where('budgets.level = ?', budget)
      .where('preferences.slug LIKE ?', "%#{preferences.join('-')}%")
      .first

    if itinerary
      render json: { id: itinerary.id }
    else
      render json: { id: nil }
    end
  end


 def save_city_image(city_name, country_name)
    slug = "#{city_name.downcase.gsub(' ', '_')}_#{country_name.downcase.gsub(' ', '_')}"
    filename = "#{slug}.jpg"
    file_path = Rails.root.join('wanderplan-client/public/city_images', filename)
    return "city_images/#{filename}" if File.exist?(file_path)

    api_key = ENV['GOOGLE_PLACES_API_KEY']
    # 1. Find Place ID via Text Search
    search_query = "#{city_name}, #{country_name}"
    require 'erb'
    search_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{ERB::Util.url_encode(search_query)}&key=#{api_key}"

    search_json = JSON.parse(URI.open(search_url).read)
    place = search_json['results'].first
    return nil unless place && place['photos']

    photo_ref = place['photos'].first['photo_reference']
    # 2. Download photo
    photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=#{photo_ref}&key=#{api_key}"
    IO.copy_stream(URI.open(photo_url), file_path)

    "city_images/#{filename}"
  end

  def gallery
  itineraries = Itinerary
    .includes(preference: [:budget, { city: :country }], activities: [:category])
    .order(created_at: :desc)
    .limit(6)

  render json: itineraries.map { |itinerary|
    activities = itinerary.activities.order(:day, :part_of_day, :id).map do |a|
      {
        id: a.id,
        day: a.day,
        part_of_day: a.part_of_day,
        name: a.name,
        description: a.description,
        address: a.address,
        category_name: a.category&.name,
        category_slug: a.category&.slug
      }
    end
    summary_categories = activities.map { |a| a[:category_name] }.uniq.compact

    city = itinerary.preference.city
    city_name = city&.name
    country_name = city&.country&.name
    city_image_url = (city_name.present? && country_name.present?) ? save_city_image(city_name, country_name) : nil

    {
      id: itinerary.id,
      title: itinerary.title,
      city: city_name,
      country: country_name,
      days: itinerary.preference.max_days,
      preferences: summary_categories,
      budget: itinerary.preference.budget&.name,
      image_url: city_image_url
    }
  }
end
end
