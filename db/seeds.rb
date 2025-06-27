# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Destroy all records in the correct order to avoid foreign key violations
Activity.destroy_all
Itinerary.destroy_all
Preference.destroy_all
CategoriesPreference.destroy_all # Join table: categories_preferences
City.destroy_all
Country.destroy_all
Budget.destroy_all
Category.destroy_all
User.destroy_all # If you want to reset users (optional, usually not needed)

puts "All records destroyed!"



# Save Budgets: name: Low Budget level: 1, name: Medium Budget level: 2, name: High Budget level: 3, name: Ultra-High Budget level:4
["Low Budget", "Medium Budget", "High Budget", "Ultra-High Budget"].each_with_index do |name, index|
  Budget.find_or_create_by!(name: name, level: index + 1)
end

# Save Categories: name: Museum, Historical Places, Restaurants, Religious Site, Theme Park, Shopping and Commercial Areas, Natural points of interest with slug: museum, historical_places, restaurants, religious_site, theme_park, shopping_and_commercial_areas, natural_points_of_interest
categories = [
  { name: "Museum", slug: "museum" },
  { name: "Historical Places", slug: "historical_places" },
  { name: "Restaurants", slug: "restaurants" },
  { name: "Religious Site", slug: "religious_site" },
  { name: "Theme Park", slug: "theme_park" },
  { name: "Shopping and Commercial Areas", slug: "shopping_and_commercial_areas" },
  { name: "Natural points of interest", slug: "natural_points_of_interest" }
]
categories.each do |category|
  Category.find_or_create_by!(name: category[:name], slug: category[:slug])
end

puts Budget.count
puts Category.count
