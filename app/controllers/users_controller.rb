# encoding: UTF-8

class UsersController < ApplicationController

	before_action :confirm_logged_in, except: [:new, :create]

	def new
		if logged_in?
			redirect_to home_page
		else
			@user = User.new
		end
	end

	def create
		if logged_in?
			redirect_to home_page
		else
			@user = User.new(user_params)
			if @user.save
				session[:user_id] = @user.id
				redirect_to home_page
			else
				flash.now[:error] = errors(@user)
				render :new
			end
		end
	end

	def show
		if params[:id].nil?
			@user = current_user
		else
			@user = User.find_by_id(params[:id])
			if @user != current_user
				flash[:error] = "Вы не можете просматривать статистику других пользователей."
				redirect_to home_page
			end
		end
		@total_stats = @user.total_stats
		@stats_for_last_month = @user.stats_for_period(30.days)
		@stats_for_today = @user.stats_for_period(1.day)
	end

	def edit
		if params[:id].nil?
			@user = current_user
		else
			@user = User.find_by_id(params[:id])
			if @user != current_user
				flash[:error] = "Вы не можете менять настройки для чужой учётной записи."
				redirect_to home_page
			end
		end
	end

	def update
		if params[:id].nil?
			@user = current_user
		else
			@user = User.find_by_id(params[:id])
			if @user != current_user
				flash[:error] = "Вы не можете менять настройки для чужой учётной записи."
				redirect_to home_page
			end
		end
		if @user == current_user
			if @user.update_attributes(user_params)
				flash[:success] = "Настройки сохранены."
				redirect_to edit_user_path
			else
				flash.now[:error] = errors(@user)
				render :edit
			end
		end
	end



private

	def user_params
		params.require(:user).permit(:name, :email, :password, :daily_limit)
	end
end
