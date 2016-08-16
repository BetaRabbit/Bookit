class Vote < ApplicationRecord
  belongs_to :book
  belongs_to :vote_session
  belongs_to :user
end
