# coding: UTF-8

require 'faker'

FactoryGirl.define do
	factory :user do
		name { Faker::Name.name.truncate(25) }
		email { Faker::Internet.email }
		password "secretpassword"
	end
end