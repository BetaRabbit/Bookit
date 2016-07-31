class Vote < ApplicationRecord
  belongs_to :book
  belongs_to :vote_session
  has_one :user
end
