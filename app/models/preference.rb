class Preference < ApplicationRecord
  belongs_to :city
  belongs_to :budget
end
