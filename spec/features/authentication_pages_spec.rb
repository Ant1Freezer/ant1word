# coding: UTF-8

require "spec_helper"

feature "Signin" do

	scenario "with invalid information" do
		visit root_path
		click_button "Войти"
		expect(current_path).to eq root_path
	end

	scenario "with valid information" do
		user = create(:user)
    sign_in user
		expect(current_url).to eq home_page
	end

end