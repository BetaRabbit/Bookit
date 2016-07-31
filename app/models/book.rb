class Book < ApplicationRecord
  has_many :votes
  has_many :vote_sessions, through: :votes
  has_and_belongs_to_many :carts
end
