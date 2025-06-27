class Itinerary < ApplicationRecord
  belongs_to :preference
  has_many :activities
end
