class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
  def new
  	@user = User.new
  end
  def create
    @user = User.new(user_params)
    
    #@user = User.new(email: user_params[:name], name: "jobob", password: user_params[:password], password_confirmation: user_params[:password_confirmation])
    if @user.save
      # Handle a successful save.
      flash[:success] = "¡Savor your New Hotness!"
      redirect_to @user
    else
      render 'new'
   end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

end
