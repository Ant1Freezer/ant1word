require 'spec_helper'

describe UsersController do
	describe "GET #new" do
		context "when logged in" do
			it "redirects to the user's home page" do
				user = create(:user)
				login(user)
				get :new
				expect(response).to redirect_to home_page
			end
		end

		context "when not logged in" do
			it "assigns a new User to @user" do
				get :new
				expect(assigns(:user)).to be_a_new User
			end

			it "renders the :new view" do
				get :new
				expect(response).to render_template :new
			end
		end
	end

	describe "POST #create" do
		context "when logged in" do
			it "redirects to the user's home page" do
				user = create(:user)
				login(user)
				post :create, user: attributes_for(:user)
				expect(response).to redirect_to home_page
			end
		end

		context "when not logged in" do
			context "with invalid parameters" do
				let(:attributes) { attributes_for(:user, email: nil) }

				it "sets a flash error message" do
					post :create, user: attributes
					expect(flash[:error]).to_not be_nil
				end

				it "doesn't create a new User" do
					expect do
						post :create, user: attributes
					end.to_not change(User, :count)
				end

				it "re-renders the :new view" do
					post :create, user: attributes
					expect(response).to render_template :new
				end
			end

			context "with valid parameters" do
				it "creates a new User" do
					expect do
						post :create, user: attributes_for(:user)
					end.to change(User, :count).by(1)
				end

				it "signs the new User in" do
					post :create, user: attributes_for(:user)
					expect(logged_in?).to be_true
				end

				it "redirects to the user's home page" do
					post :create, user: attributes_for(:user)
					expect(response).to redirect_to home_page
				end
			end
		end
	end

	describe "GET #show" do
		context "when not logged in" do
			it "redirects to the home page" do
				user = create(:user)
				get :show, id: user
				expect(response).to redirect_to root_url
			end
		end

		context "when logged in" do
			let(:user) { create(:user) }
			before(:each) { login(user) }

			it "changes actual dates for repetitions" do
				flashcard = create(:flashcard, user: user)
				session[:date] = Date.today
				first_repetition = flashcard.repetitions.first
				first_repetition.actual_date = first_repetition.planned_date = session[:date] - 3.days
				first_repetition.save
				get :show, id: user
				expect(first_repetition.reload.actual_date).to eq session[:date]
			end

			it "changes the current date" do
				session[:date] = Date.today - 1.day
				get :show, id: user
				expect(session[:date]).to eq Date.today
			end

			shared_examples "showing the current user" do
				it "assigns the current user to @user" do
					expect(assigns(:user)).to eq user
				end

				it "sets three stats variables" do
					expect(assigns(:total_stats)).to_not be_nil
					expect(assigns(:stats_for_last_month)).to_not be_nil
					expect(assigns(:stats_for_today)).to_not be_nil
				end

				it "renders the :show view" do
					expect(response).to render_template :show
				end
			end

			context "when trying to #show the current user" do
				before(:each) { get :show, id: user }

				it_behaves_like "showing the current user"
			end

			context "when trying to #show a user with any other id" do
				let(:another_user) { create(:user) }

				it "redirects to the user's home page" do
					get :show, id: another_user
					expect(response).to redirect_to home_page
				end

				it "sets a flash[:error] message" do
					get :show, id: another_user
					expect(flash[:error]).to_not be_nil
				end
			end

			context "when not supplying an id" do
				before(:each) { get :show }

				it_behaves_like "showing the current user"
			end
		end

	end

	describe "GET #edit" do
		let(:user) { create(:user) }
		context "when not logged in" do
			it "redirects to the home page" do
				get :edit, id: user
				expect(response).to redirect_to root_url
			end
		end

		context "when logged in" do
			before(:each) { login(user) }

			it "changes actual dates for repetitions" do
				flashcard = create(:flashcard, user: user)
				first_repetition = flashcard.repetitions.first
				first_repetition.actual_date = first_repetition.planned_date = Date.today - 3.days
				first_repetition.save
				get :edit, id: user
				expect(first_repetition.reload.actual_date).to eq Date.today
			end

			it "changes the current date" do
				session[:date] = Date.today - 1.day
				get :edit, id: user
				expect(session[:date]).to eq Date.today
			end

			shared_examples "editing the current user" do
				it "assigns the current user to @user" do
					expect(assigns(:user)).to eq user
				end

				it "renders the :edit view" do
					expect(response).to render_template :edit
				end
			end

			context "when trying to #edit the current user" do
				before(:each) { get :edit, id: user }

				it_behaves_like "editing the current user"
			end

			context "when trying to #edit a user with any other id" do
				let(:another_user) { create(:user) }

				it "redirects to the user's home page" do
					get :edit, id: another_user
					expect(response).to redirect_to home_page
				end

				it "sets a flash[:error] message" do
					get :edit, id: another_user
					expect(flash[:error]).to_not be_nil
				end
			end

			context "when not supplying an id" do
				before(:each) { get :edit }

				it_behaves_like "editing the current user"
			end
		end	
	end

	describe "PUT #update" do
		context "when not logged in" do
			it "redirects to the home page" do
				patch :update, id: create(:user), user: attributes_for(:user)
				expect(response).to redirect_to root_url
			end
		end

		context "when logged in" do
			let(:user) { create(:user) }
			before(:each) { login(user) }

			it "changes actual dates for repetitions" do
				flashcard = create(:flashcard, user: user)
				first_repetition = flashcard.repetitions.first
				first_repetition.actual_date = first_repetition.planned_date = Date.today - 3.days
				first_repetition.save
				patch :update, id: user, user: attributes_for(:user)
				expect(first_repetition.reload.actual_date).to eq Date.today
			end

			it "changes the current date" do
				session[:date] = Date.today - 1.day
				patch :update, id: user, user: attributes_for(:user)
				expect(session[:date]).to eq Date.today
			end

			context "when trying to #update the current user" do
				

				it "assigns the current user to @user" do
					patch :update,
						id: user,
						user: { name: "John Doe",
							daily_limit: 20 }
					expect(assigns(:user)).to eq user
				end

				context "with valid attributes" do
					before(:each) {
						patch :update,
						id: user,
						user: { name: "John Doe",
							daily_limit: 20 } }

					it "updates the user's info in the database" do
						user.reload
						expect(user.name).to eq "John Doe"
						expect(user.daily_limit).to eq 20
					end

					it "sets a flash[:success] message" do
						expect(flash[:success]).to_not be_nil
					end

					it "redirects to the edit page" do
						expect(response).to redirect_to edit_user_url
					end
				end

				context "with invalid attributes" do
					before(:each) {
						patch :update,
						id: user,
						user: { email: "" } }
					
					it "doesn't update the user's info in the database" do
						expect(user.email).to_not eq ""
					end

					it "sets a flash[:error] message" do
						expect(flash[:error]).to_not be_nil
					end

					it "re-renders the :edit view" do
						expect(response).to render_template :edit
					end
				end
			end

			context "when trying to #update a user with any other id" do
				let(:another_user) { create(:user) }
				before(:each) { patch :update, id: another_user, user: attributes_for(:user) }

				it "redirects to the user's home page" do
					expect(response).to redirect_to home_page
				end

				it "sets a flash[:error] message" do
					expect(flash[:error]).to_not be_nil
				end
			end
		end
	end
end