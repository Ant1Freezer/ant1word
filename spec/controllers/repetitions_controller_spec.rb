require 'spec_helper'
require 'shared_examples'

describe RepetitionsController do
	let(:user) { create(:user) }
	let(:first_flashcard) { create(:flashcard, user: user) }
	let(:second_flashcard) { create(:flashcard, user: user) }
	let(:third_flashcard) { create(:flashcard, user: user) }
	let!(:first_repetition) do
		repetition = first_flashcard.repetitions.first
		repetition.update_attributes(actual_date: Date.today + 4.days)
		repetition
	end
	let!(:second_repetition) do
		repetition = second_flashcard.repetitions.first
		repetition.update_attributes(actual_date: Date.today + 4.days)
		repetition
	end
	let!(:third_repetition) do
		repetition = third_flashcard.repetitions.first
		repetition.update_attributes(actual_date: Date.today + 5.days)
		repetition
	end


	describe "guest access" do
		describe "GET #index" do
			before(:each) { get :index }
			it_behaves_like "restricted pages"
		end

		describe "PUT #update" do
			before(:each) { patch :update, id: first_repetition, successful: true }
			it_behaves_like "restricted pages"
		end
	end

	describe "user access" do
		# ??? Почему, если поставить :all вместо :each, тесты не выполняются?
		before(:each) { login user }

		describe "GET #index" do
			context "when there are no repetitions for today" do
				it "redirects to the #stats action" do
					get :index
					expect(response).to redirect_to stats_url
				end
			end

			context "when there are some repetitions for today" do
				before(:each) { Timecop.travel 4.days.from_now }
				after(:each) { Timecop.return }
				
				it "populates the @repetitions array" do
					get :index
					expect(assigns(:repetitions)).to match_array [
						first_repetition,
						second_repetition
					]
				end

				context "when a valid repetition id is supplied" do
					it "assigns the @current_repetition variable" do
						get :index, repetition_id: first_repetition
						expect(assigns(:current_repetition)).to eq first_repetition
					end
				end

				context "when an invalid repetition id is supplied" do
					it "assigns a randomly selected value to the @current_repetition variable" do
						get :index, repetition_id: first_repetition.id + 100
						expect([first_repetition, second_repetition]).
							to include assigns(:current_repetition)
					end
				end

				context "when a repetition id is not supplied" do
					it "assigns a randomly selected value to the @current_repetition variable" do
						get :index
						expect([first_repetition, second_repetition]).
							to include assigns(:current_repetition)
					end
				end

				it "sets the current_text and current_view variables" do
					get :index
					expect(assigns(:current_text)).to_not be_empty
					expect(assigns(:current_view)).to eq "front"
				end

				it "renders the :index view" do
					get :index
					expect(response).to render_template :index
				end
			end
		end

		describe "PUT #update" do
			before(:each) { Timecop.travel 4.days.from_now }
			after(:each) { Timecop.return }
			
			context "for a repetition that should be run today" do
				context "with a valid :successful attribute" do
					it "updates the requested repetition" do
						patch :update, id: first_repetition, successful: true
						first_repetition.reload
						expect(first_repetition.successful).to be_true
						expect(first_repetition.run).to be_true
					end

					it "creates another repetition" do
						expect do
							patch :update, id: first_repetition, successful: true
						end.to change(Repetition, :count).by(1)
					end

					it "redirects to the #index action" do
						patch :update, id: first_repetition, successful: true
						expect(response).to redirect_to repetitions_url
					end
				end

				context "without a :successful attribute" do
					it "does not update the requested repetition" do
						patch :update, id: first_repetition
						expect(first_repetition.successful).to be_nil
						expect(first_repetition.run).to be_false
					end

					it "does not create another repetition" do
						expect do
							patch :update, id: first_repetition
						end.to_not change(Repetition, :count)
					end

					it "sets a flash[:error] message" do
						patch :update, id: first_repetition
						expect(flash.to_hash).to_not eq({ })
					end

					it "redirects to the #index action" do
						patch :update, id: first_repetition
						expect(response).to redirect_to repetitions_url
					end
				end
			end

			context "for a repetition that should not be run today" do
				it "does not update the requested repetition" do
					patch :update, id: third_repetition, successful: true
					expect(third_repetition.successful).to be_nil
					expect(third_repetition.run).to be_false
				end

				it "does not create another repetition" do
					expect do
						patch :update, id: third_repetition, successful: true
					end.to_not change(Repetition, :count)
				end

				it "redirects to the #index action" do
					patch :update, id: third_repetition, successful: true
					expect(response).to redirect_to repetitions_url
				end
			end
		end
	end
end