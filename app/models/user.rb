class User < ApplicationRecord
  # Relations
  has_many :loans, dependent: :restrict_with_error
  has_many :books, through: :loans
  
  # Validations
  validates :firstname, :lastname, :email, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit contenir 10 chiffres" }, allow_blank: true
  
  # Callbacks
  before_save :normalize_names
  
  # Scopes
  scope :active_borrowers, -> { joins(:loans).where(loans: { returned_on: nil }).distinct }
  scope :search, ->(query) { 
    where('firstname ILIKE ? OR lastname ILIKE ? OR email ILIKE ?', 
          "%#{query}%", "%#{query}%", "%#{query}%") if query.present?
  }
  
  # Méthode pour obtenir le nom complet
  def full_name
    "#{firstname} #{lastname}"
  end
  
  # Méthodes d'instance supplémentaires
  def active_loans
    loans.where(returned_on: nil)
  end
  
  def past_loans
    loans.where.not(returned_on: nil)
  end
  
  def can_borrow?
    active_loans.count < 5  # Limite de 5 emprunts simultanés par exemple
  end
  
  def overdue_loans
    active_loans.where('due_date < ?', Date.today)
  end
  
  def has_overdue_loans?
    overdue_loans.exists?
  end
  
  private
  
  def normalize_names
    self.firstname = firstname.capitalize if firstname.present?
    self.lastname = lastname.upcase if lastname.present?
  end
end