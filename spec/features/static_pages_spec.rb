# coding: UTF-8

require 'spec_helper'

feature "Static pages" do
  scenario "visiting the intro page" do
    visit intro_path
    expect(page).to have_content("Читайте интересные тексты")
  end
end
