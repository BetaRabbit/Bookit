class Cart < ApplicationRecord
  belongs_to :vote_session
  has_and_belongs_to_many :books
end
