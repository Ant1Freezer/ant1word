module UserMacros
	def login(user)
		session[:user_id] = user.id
	end

	def logged_in?
		not session[:user_id].nil?
	end

	def home_page
		new_flashcard_url
	end
end