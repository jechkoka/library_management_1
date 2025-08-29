class Loan < ApplicationRecord
  belongs_to :book
  belongs_to :user
  validates :borrowed_on, :due_date, presence: true
end
