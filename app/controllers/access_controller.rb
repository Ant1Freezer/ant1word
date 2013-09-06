# encoding: UTF-8

class AccessController < ApplicationController
  
  def attempt_login
    authorized_user = User.authenticate params[:email].downcase, params[:password]
    if authorized_user
      session[:user_id] = authorized_user.id
      redirect_to new_flashcard_path
    else
      flash[:error] = "Неверный логин / пароль."
      redirect_to root_url
    end
  end
  
  def logout
    session[:user_id] = nil
    redirect_to root_url
  end
  
end
