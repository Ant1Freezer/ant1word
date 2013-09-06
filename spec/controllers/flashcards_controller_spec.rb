require 'spec_helper'
require 'shared_examples'

describe FlashcardsController do

	describe "guest access" do
		let(:user) { create(:user) }
		let!(:flashcard) { create(:flashcard, user: user) }

		describe "GET #index" do
			before { get :index }
			it_behaves_like "restricted pages"
		end

		describe "GET #new" do
			before { get :new }
			it_behaves_like "restricted pages"
		end

		describe "POST #create" do
			before { post :create, flashcard: attributes_for(:flashcard) }
			it_behaves_like "restricted pages"
		end

		describe "GET #edit" do
			before { get :edit, id: flashcard }
			it_behaves_like "restricted pages"
		end

		describe "PUT #update" do
			before { patch :update, id: flashcard, flashcard: attributes_for(:flashcard) }
			it_behaves_like "restricted pages"
		end

		describe "DELETE #destroy" do
			before { delete :destroy, id: flashcard }
			it_behaves_like "restricted pages"
		end

		describe "PUT #undelete" do
			before { patch :undelete, flashcards: [flashcard] }
			it_behaves_like "restricted pages"
		end
	end



	describe "user access" do
		let(:user) { create(:user) }
		let!(:flashcard) { create(:flashcard, user: user) }
		let!(:deleted_flashcard) { create(:deleted_flashcard, user: user) }
		let(:another_user) { create(:user) }
		let!(:another_users_flashcard) { create(:flashcard, user: another_user) }
		before(:each) { login user }

		describe "GET #index" do
			let(:yesterdays_flashcard) { create(:flashcard, user: user) }
			before(:each) do
				# TODO: как избавиться от этой строчки?
				yesterdays_flashcard.update_attribute(:created_at, 1.day.ago)
				get :index
			end

			it "populates the @flashcards_grouped_by_date array" do
				expect(assigns(:flashcards_grouped_by_date)).to eq({
					1.day.ago.localtime.to_date => [yesterdays_flashcard],
					Date.today => [flashcard] })
			end

			it "populates the @deleted_flashcards array" do
				expect(assigns(:deleted_flashcards)).to eq [deleted_flashcard]
			end

			it "renders the :index view" do
				expect(response).to render_template :index
			end
		end

		describe "GET #new" do
			it "assigns a new Flashcard to @flashcard" do
				get :new
				expect(assigns(:flashcard)).to be_a_new(Flashcard)
			end

			it "renders the :form view" do
				get :new
				expect(response).to render_template :form
			end
		end

		describe "POST #create" do
			context "with invalid attributes" do
				let(:invalid_attributes) { attributes_for(:flashcard, front_text: "") }
				
				it "sets a flash[:error] message" do
					post :create, flashcard: invalid_attributes
					expect(flash.to_hash).to_not eq({ })
				end

				it "doesn't create a new Flashcard" do
					expect do
						post :create, flashcard: invalid_attributes
					end.to_not change(Flashcard, :count)
				end

				it "re-renders the :form view" do
					post :create, flashcard: invalid_attributes
					expect(response).to render_template :form
				end
			end

			context "with valid attributes" do
				let(:valid_attributes) { attributes_for(:flashcard) }

				it "creates a new flashcard" do
					expect do
						post :create, flashcard: valid_attributes
					end.to change(Flashcard, :count).by(1)
				end

				it "redirects to the #new action" do
					post :create, flashcard: valid_attributes
					expect(response).to redirect_to new_flashcard_url
				end
			end
		end

		shared_examples "unavailable flashcard" do
			it "sets a flash[:error] message" do
				expect(flash.to_hash).to_not eq({ })
			end
			it "redirects to the home page" do
				expect(response).to redirect_to home_page
			end
		end

		describe "GET #edit" do

			context "when the flashcard doesn't exist" do
				before { get :edit, id: flashcard.id + 100 }
				it_behaves_like "unavailable flashcard"
			end

			context "when the flashcard belongs to another user" do
				before { get :edit, id: another_users_flashcard }
				it_behaves_like "unavailable flashcard"
			end

			context "when the flashcard belongs to the current user" do
				it "assigns the requested flashcard to @flashcard" do
					get :edit, id: flashcard
					expect(assigns(:flashcard)).to eq flashcard
				end

				it "renders the :form view" do
					get :edit, id: flashcard
					expect(response).to render_template :form
				end
			end
		end

		describe "PUT #update" do
			context "when the flashcard doesn't exist" do
				before { patch :update, id: flashcard.id + 100, flashcard: attributes_for(:flashcard) }
				it_behaves_like "unavailable flashcard"
			end

			context "when the flashcard belongs to another user" do
				before { patch :update, id: another_users_flashcard, flashcard: attributes_for(:flashcard) }
				it_behaves_like "unavailable flashcard"
			end

			context "when the flashcard belongs to the current user" do
				context "with invalid attributes" do
					let(:invalid_attributes) { attributes_for(:flashcard, front_text: "", back_text: "blah-blah") }
					before(:each) { patch :update, id: flashcard, flashcard: invalid_attributes }

					it "sets a flash[:error] message" do
						expect(flash.to_hash).to_not eq({ })
					end

					it "doesn't alter the requested flashcard" do
						expect(flashcard.reload.back_text).to_not eq "blah-blah"
					end

					it "re-renders the :form view" do
						expect(response).to render_template :form
					end
				end

				context "with valid attributes" do
					let(:valid_attributes) { attributes_for(:flashcard, front_text: "blah-blah") }
					before(:each) { patch :update, id: flashcard, flashcard: valid_attributes }
					
					it "alters the requested flashcard" do
						expect(flashcard.reload.front_text).to eq "blah-blah"
					end

					it "redirects to the #index page anchored on the flashcard" do
						expect(response).to redirect_to flashcards_url(anchor: flashcard)
					end
				end
			end
		end

		describe "DELETE #destroy" do
			context "when the flashcard doesn't exist" do
				before { delete :destroy, id: flashcard.id + 100 }
				it_behaves_like "unavailable flashcard"
			end

			context "when the flashcard belongs to another user" do
				before { delete :destroy, id: another_users_flashcard }
				it_behaves_like "unavailable flashcard"
			end

			context "when the flashcard belongs to the current user" do
				before(:each) { delete :destroy, id: flashcard}

				it "marks the flashcard as deleted" do
					expect(flashcard.reload.deleted).to be_true
				end

				it "redirects to the #index page" do
					expect(response).to redirect_to flashcards_url
				end
			end
		end

		describe "PUT #undelete" do
			context "when any of the flashcards doesn't exist" do
				before(:each) { patch :undelete, flashcards: [deleted_flashcard, deleted_flashcard.id + 100] }
				it_behaves_like "unavailable flashcard"
			end

			context "when any of the flashcards belongs to another user" do
				before(:each) { patch :undelete, flashcards: [deleted_flashcard, another_users_flashcard] }
				it_behaves_like "unavailable flashcard"
			end

			context "when all the flashcards belong to the current user" do
				it "marks all listed deleted flashcards as not deleted" do
					expect do
						patch :undelete, flashcards: [deleted_flashcard]
					end.to change{user.flashcards.deleted.count}.from(1).to(0)
				end

				it "doesn't do anything with listed flashcards that are not deleted" do
					expect do
						patch :undelete, flashcards: [flashcard]
					end.to_not change{flashcard}
				end

				it "redirects to the #index page" do
					patch :undelete, flashcards: [deleted_flashcard, flashcard]
					expect(response).to redirect_to flashcards_url
				end
			end
		end
	end
end