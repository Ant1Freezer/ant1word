# == Schema Information
#
# Table name: flashcards
#
#  id                                 :integer          not null, primary key
#  user_id                            :integer
#  front_text                         :text
#  back_text                          :text
#  consecutive_successful_repetitions :integer          default(0)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  deleted                            :boolean          default(FALSE)
#  learned_on                         :date
#

require 'spec_helper'

describe Flashcard do
	before :each do
		@user = create(:user)
		@flashcard = build(:flashcard, user: @user)
	end

	it "is valid with front text, back text, a user id and 'deleted' set to false" do
		expect(@flashcard).to be_valid
	end

	it "is invalid without front text" do
		@flashcard.front_text = nil
		expect(@flashcard).to have(1).errors_on(:front_text)
	end

	it "is invalid with blank front text" do
		# Чтобы этот тест ломался, нужно писать не presence: true, а length: { minimum: 1 }
		@flashcard.front_text = "   "
		expect(@flashcard).to have(1).errors_on(:front_text)
	end

	it "is invalid without back text" do
		@flashcard.back_text = nil
		expect(@flashcard).to have(1).errors_on(:back_text)
	end

	it "is invalid with blank back text" do
		@flashcard.back_text = "   "
		expect(@flashcard).to have(1).errors_on(:back_text)
	end

	it "is invalid without 'deleted' field specified" do
		@flashcard.deleted = nil
		expect(@flashcard).to have(1).errors_on(:deleted)
	end

	context "user" do
		it "is invalid without a user id" do
			@flashcard.user_id = nil
			expect(@flashcard).to have(2).errors_on(:user_id)
		end

		it "is invalid with a non-existent user id" do
			@flashcard.user_id = 100
			expect(@flashcard).to have(1).errors_on(:user)
		end
	end

	context "'learned_on' date" do
		it "is valid without a 'learned_on' date" do
			@flashcard.learned_on = nil
			expect(@flashcard).to be_valid
		end

		it "is valid with 'learned_on' date set in the past" do
			@flashcard.learned_on = Date.today - 2.days
			expect(@flashcard).to be_valid
		end

		it "is valid with 'learned_on' date set today" do
			@flashcard.learned_on = Date.today
			expect(@flashcard).to be_valid
		end

		it "is invalid with 'learned_on' date set in the future" do
			@flashcard.learned_on = Date.today + 3.days
			expect(@flashcard).to have(1).errors_on(:learned_on)
		end
	end

	describe "querying" do
		before :each do
			@flashcard.save
			@deleted_flashcard = create(:flashcard, user: @user, deleted: true)
		end

		context "in default scope" do
			it "should not find a deleted flashcard" do
				expect(Flashcard.all).to eq [@flashcard]
			end
		end

		context "unscoped" do
			it "should find the deleted flashcard" do
				expect(Flashcard.unscoped).to match_array [@flashcard, @deleted_flashcard]
			end
		end
	end

	describe "repetitions" do
		context "first repetition" do
			before :each do
				@flashcard.save
			end

			it "should be set for no more than three days from now" do
				expect(@flashcard.repetitions.first.planned_date).to be_in(
					(Date.today + 1.day)..(Date.today + 3.days))
			end
			
			context "consecutive successful repetitions" do
				it "should be initially set to 0" do
					expect(@flashcard.consecutive_successful_repetitions).to be_zero
				end
			end
		end

		context "running a successful repetition" do
			before :each do
				@flashcard.save
				@first_repetition = @flashcard.repetitions.first
				@first_repetition.update_attribute(:successful, true)
			end

			it "should have two repetitions" do
				expect(@flashcard.repetitions.count).to eq 2
			end
			
			context "second repetition" do
				it "should be set 2 to 9 days from the first repetition's actual date" do
					@second_repetition = @flashcard.repetitions.second
					expect(@second_repetition.planned_date).to be_in(
						(@first_repetition.actual_date + 2.days)..
						(@first_repetition.actual_date + 9.days))
				end
			end

			context "consecutive successful repetitions" do
				it "should equal 1" do
					expect(@flashcard.reload.consecutive_successful_repetitions).to eq 1
				end
			end
		end

		context "faking the last repetition" do
			before :each do
				@flashcard.update_attribute(:consecutive_successful_repetitions, 2)
				@last_repetition = @flashcard.repetitions.first
				@last_repetition.update_attribute(:successful, true)
			end

			it "should become learned" do
				expect(@flashcard.reload).to be_learned
			end

			context "repetition count" do
				it "should not increase" do
					expect(@flashcard.repetitions.count).to eq 1
				end
			end

		end
	end

	context "learned" do
		it "should not be learned if it has two consecutive successful repetitions" do
			@flashcard.consecutive_successful_repetitions = 2
			expect(@flashcard).to_not be_learned
		end
		it "should be learned if it has three consecutive successful repetitions" do
			@flashcard.consecutive_successful_repetitions = 3
			expect(@flashcard).to be_learned
		end
		it "should be learned if it has four consecutive successful repetitions" do
			@flashcard.consecutive_successful_repetitions = 4
			expect(@flashcard).to be_learned
		end
	end

end
