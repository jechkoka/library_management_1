# app/controllers/loans_controller.rb
class LoansController < ApplicationController
  before_action :set_loan, only: [:show, :edit, :update, :destroy, :return_book]

  def index
    @active_loans = Loan.where(returned_on: nil).order(due_date: :asc)
    @past_loans = Loan.where.not(returned_on: nil).order(returned_on: :desc)
  end

  def show
  end

  def new
    @loan = Loan.new
    # Filtrer pour n'afficher que les livres disponibles
    @available_books = Book.where(available: true)
    @users = User.all
  end

  def create
    @loan = Loan.new(loan_params)
    @loan.borrowed_on = Date.today
    @loan.due_date = Date.today + 14.days # Par défaut, emprunt pour 14 jours
    @loan.status = 'emprunté'
    
    # Vérifier si l'utilisateur peut emprunter plus de livres
    unless @loan.user.can_borrow?
      redirect_to @loan.user, alert: "Cet utilisateur a atteint sa limite d'emprunts."
      return
    end
    
    # Vérifier si le livre est disponible
    book = Book.find(loan_params[:book_id])
    
    if book.available?
      if @loan.save
        # Marquer le livre comme non disponible
        book.update(available: false)
        redirect_to @loan, notice: 'Emprunt enregistré avec succès.'
      else
        @available_books = Book.where(available: true)
        @users = User.all
        render :new
      end
    else
      redirect_to books_path, alert: 'Ce livre n\'est pas disponible pour l\'emprunt.'
    end
  end

  def edit
    @books = Book.all
    @users = User.all
  end

  def update
    old_book = @loan.book
    
    if @loan.update(loan_params)
      # Si le livre a changé, mettre à jour la disponibilité des deux livres
      if old_book.id != @loan.book_id
        old_book.update(available: true)
        @loan.book.update(available: false)
      end
      redirect_to @loan, notice: 'Emprunt mis à jour avec succès.'
    else
      @books = Book.all
      @users = User.all
      render :edit
    end
  end

  def destroy
    # Si on supprime un emprunt actif, rendre le livre disponible à nouveau
    if @loan.returned_on.nil?
      @loan.book.update(available: true)
    end
    
    @loan.destroy
    redirect_to loans_path, notice: 'Emprunt supprimé avec succès.'
  end

  def return_book
    if @loan.returned_on.nil?
      @loan.returned_on = Date.today
      @loan.status = 'retourné'
      
      if @loan.save
        # Rendre le livre disponible à nouveau
        @loan.book.update(available: true)
        redirect_to loans_path, notice: 'Livre retourné avec succès.'
      else
        redirect_to @loan, alert: 'Erreur lors du retour du livre.'
      end
    else
      redirect_to @loan, alert: 'Ce livre a déjà été retourné.'
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:book_id, :user_id, :due_date)
  end
end