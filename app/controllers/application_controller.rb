# encoding: UTF-8
	
class ApplicationController < ActionController::Base
  
  # Чтобы хелперы были доступны во всех контроллерах.
  include ApplicationHelper

  protect_from_forgery

  before_action :adjust_current_date
  before_action :wipe_deleted_flashcards
  
  # Для использования этих методов внутри view.
  helper_method :current_user
  helper_method :logged_in?
  helper_method :current_date
  helper_method :home_page
  
  def index
    if logged_in?
      redirect_to new_flashcard_path
    end
  end
  
  def logged_in?
    not session[:user_id].nil?
  end

  def current_date
    session[:date]
  end

  def home_page
    new_flashcard_url
  end


  
  protected
  
  def confirm_logged_in
    if logged_in?
      # При каждом действии, если пользователь залогинен, сдвигаем все повторы, если хоть один остался с предыдущих дат.
      current_user.repetitions.adjust_dates(current_date)
      return true
    else
      flash[:error] = "Пожалуйста, авторизуйтесь."
      redirect_to root_url
      return false
    end
  end

  def current_user
    User.find_by_id session[:user_id]
  end  



  private

  # Чтобы всё приложение вычисляло дату единым образом, используется одна переменная сессии, которая обновляется перед каждым действием.
  def adjust_current_date
    session[:date] = Date.today
    return true
  end

  def wipe_deleted_flashcards
    if current_user
      flashcards_deleted_before_today = current_user.flashcards.deleted_before(current_date)
      flashcards_deleted_before_today.each { |flashcard| flashcard.destroy }
    end
  end
  
end
