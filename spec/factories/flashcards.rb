# coding: UTF-8

require 'faker'

FactoryGirl.define do

	factory :flashcard do
		association :user

    front_text { Faker::Lorem.paragraph }
    back_text { Faker::Lorem.word }

    factory :deleted_flashcard do
    	deleted true
    end
  end
end