class UsersPreference < ApplicationRecord
  belongs_to :user
  belongs_to :preference
end
