class Book < ApplicationRecord
  # Relations
  has_many :loans, dependent: :destroy
  has_many :users, through: :loans

  # Validations
  validates :title, :author, presence: true
  validates :isbn, uniqueness: true, allow_blank: true
  validates :published_year, numericality: { 
    less_than_or_equal_to: -> { Date.today.year },
    greater_than: 0
  }, allow_blank: true

  # Scopes (pour faciliter les requêtes courantes)
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :search, ->(query) { 
    where('title ILIKE ? OR author ILIKE ?', "%#{query}%", "%#{query}%") if query.present?
  }

  # Méthodes d'instance
  def current_loan
    loans.where(returned_on: nil).first
  end

  def borrowed_by
    current_loan&.user
  end

  def due_date
    current_loan&.due_date
  end

  def overdue?
    return false unless current_loan
    current_loan.due_date < Date.today
  end
end