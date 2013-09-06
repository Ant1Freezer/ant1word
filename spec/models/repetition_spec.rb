# == Schema Information
#
# Table name: repetitions
#
#  id           :integer          not null, primary key
#  flashcard_id :integer
#  planned_date :date
#  actual_date  :date
#  run          :boolean          default(FALSE)
#  successful   :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Repetition do
	before :each do
		@user = create(:user)
		@flashcard = create(:flashcard, user: @user)
		@repetition = @flashcard.repetitions.build(
			planned_date: Date.today + 1.day,
			actual_date: Date.today + 1.day)
	end

	it "is valid with a planned date and actual date" do
		expect(@repetition).to be_valid
	end

	it "is invalid without a planned date" do
		@repetition.planned_date = nil
		expect(@repetition).to have(1).errors_on(:planned_date)
	end

	context "actual date" do
		it "is invalid with actual date less than planned date" do
			@repetition.planned_date += 1.day
			expect(@repetition).to have(1).errors_on(:actual_date)
		end

		it "is invalid without an actual date and throws two validation errors" do
			@repetition.actual_date = nil
			expect(@repetition).to have(2).errors_on(:actual_date)
		end
	end

	context "flashcard" do
		it "is invalid without a flashcard id" do
			@repetition.flashcard_id = nil
			expect(@repetition).to have(2).errors_on(:flashcard_id)
		end

		it "is invalid with a nonexistent flashcard" do
			@repetition.flashcard_id = 100
			expect(@repetition).to have(1).errors_on(:flashcard)
		end
	end

	context "with 'run' set to true" do
		before :each do
			@repetition.run = true
		end
		
		it "is invalid with an actual date in the future" do
			expect(@repetition).to have(1).errors_on(:run)
		end
		
		it "is valid with an actual date today" do
			@repetition.actual_date = @repetition.planned_date = Date.today
			expect(@repetition).to be_valid
		end
		
		it "is valid with an actual date in the past" do
			@repetition.actual_date = @repetition.planned_date = Date.today - 1.day
			expect(@repetition).to be_valid
		end
	end
end
