class VoteSession < ApplicationRecord
  has_many :votes
  has_many :books, through: :votes
  has_one :cart
end
