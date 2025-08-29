# app/controllers/books_controller.rb
class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.all
    
    # Recherche par titre ou auteur
    if params[:search].present?
      @books = @books.where('title ILIKE ? OR author ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # Filtre par disponibilité
    if params[:available].present?
      @books = @books.where(available: params[:available] == "true")
    end
    
    # Filtre par catégorie
    if params[:category].present?
      @books = @books.where(category: params[:category])
    end
  end

  def show
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to @book, notice: 'Livre ajouté avec succès.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: 'Livre mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: 'Livre supprimé avec succès.'
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :description, :isbn, :published_year, :category, :available)
  end
end