class CategoriesPreference < ApplicationRecord
  belongs_to :category
  belongs_to :preference
end
