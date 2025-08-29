# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
    # Récupérer les emprunts en cours de cet utilisateur
    @active_loans = @user.loans.where("returned_on IS NULL")
    # Récupérer l'historique des emprunts
    @past_loans = @user.loans.where.not(returned_on: nil)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'Utilisateur créé avec succès.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Utilisateur mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    if @user.loans.where(returned_on: nil).any?
      redirect_to @user, alert: 'Impossible de supprimer cet utilisateur car il a des emprunts en cours.'
    else
      @user.destroy
      redirect_to users_path, notice: 'Utilisateur supprimé avec succès.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone)
  end
end