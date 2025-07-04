class Itinerary < ApplicationRecord
  belongs_to :preference
  has_many :activities
  has_many :favourites
  has_many :favourited_by, through: :favourites, source: :user
end
