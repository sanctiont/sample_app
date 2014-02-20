class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    #@user = User.find(params[:id]) #not needed bc of before_action
  end

  def update
    #@user = User.find(params[:id]) #not needed bc of before_action
    if @user.update_attributes(user_params)
      # Handle a successful update.
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def new
    if signed_in? 
      redirect_to root_url, notice: "Already logged in"    
    else
  	 @user = User.new
    end
  end

  def create
    if signed_in? 
      redirect_to root_url, notice: "Already logged in"
    else
     @user = User.new(user_params)
    
     #@user = User.new(email: user_params[:name], name: "jobob", password: user_params[:password], password_confirmation: user_params[:password_confirmation])
     if @user.save
       # Handle a successful save.
       sign_in @user
       flash[:success] = "¡Savor your New Hotness!"
       redirect_to @user
     else
       render 'new'
    end
   end
  end

  def destroy
    if current_user?(User.find(params[:id]))
      redirect_to root_url
    else
     User.find(params[:id]).destroy
     flash[:success] = "User deleted."
     redirect_to users_url
    end
    
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

# Before filters

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
