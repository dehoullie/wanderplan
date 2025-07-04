class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :favourites
  has_many :favourite_itineraries, through: :favourites, source: :itinerary

  validates :name, presence: true

  def jwt_subject
    id
  end

  def me
    render json: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.name
    }
  end
end
