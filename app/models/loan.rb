class Loan < ApplicationRecord
  # Relations
  belongs_to :book
  belongs_to :user

  # Validations
  validates :borrowed_on, :due_date, presence: true
  validate :due_date_after_borrowed_on
  validate :book_available_for_loan, on: :create
  validate :user_can_borrow, on: :create

  # Callbacks
  before_create :set_default_values
  after_create :mark_book_as_unavailable
  after_update :update_book_availability, if: :returned_on_changed?

  # Scopes
  scope :active, -> { where(returned_on: nil) }
  scope :returned, -> { where.not(returned_on: nil) }
  scope :overdue, -> { active.where('due_date < ?', Date.today) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_book, ->(book_id) { where(book_id: book_id) }

  # Méthodes d'instance
  def overdue?
    returned_on.nil? && due_date < Date.today
  end

  def days_overdue
    return 0 unless overdue?
    (Date.today - due_date).to_i
  end

  def returned?
    returned_on.present?
  end

  def return_book!(return_date = Date.today)
    update(returned_on: return_date)
  end

  private

  def due_date_after_borrowed_on
    return if due_date.blank? || borrowed_on.blank?

    if due_date < borrowed_on
      errors.add(:due_date, "doit être postérieure à la date d'emprunt")
    end
  end

  def book_available_for_loan
    return if book.blank?

    unless book.available?
      errors.add(:book, "n'est pas disponible pour l'emprunt")
    end
  end

  def user_can_borrow
    return if user.blank?

    # Vous pouvez ajouter une limite au nombre d'emprunts simultanés
    max_loans = 5 # par exemple
    if user.loans.active.count >= max_loans
      errors.add(:user, "a atteint la limite maximale d'emprunts simultanés (#{max_loans})")
    end
  end

  def set_default_values
    self.borrowed_on ||= Date.today
    self.due_date ||= Date.today + 14.days # Emprunt par défaut de 2 semaines
    self.status ||= 'emprunté'
  end

  def mark_book_as_unavailable
    book.update(available: false)
  end

  def update_book_availability
    if returned_on.present?
      book.update(available: true)
      self.status = 'retourné'
      save
    end
  end
end