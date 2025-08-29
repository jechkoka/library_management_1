class User < ApplicationRecord
  has_many :loans
  has_many :books, through: :loans
  
  validates :firstname, :lastname, :email, presence: true
  validates :email, uniqueness: true
  
  # Méthode pour obtenir le nom complet
  def full_name
    "#{firstname} #{lastname}"
  end
end