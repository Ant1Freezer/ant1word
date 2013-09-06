# coding: UTF-8
# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(25)
#  email           :string(100)
#  hashed_password :string(40)
#  salt            :string(40)
#  is_admin        :boolean          default(FALSE)
#  daily_limit     :integer          default(10)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


require 'spec_helper'

describe User do
	let(:user) { create(:user) }

	it "responds to :name" do
		expect(user).to respond_to :name
	end

	it "responds to :email" do
		expect(user).to respond_to :email
	end

	it "is valid" do
		expect(user).to be_valid
	end

	it "is invalid when name is too long" do
		user.name = "a" * 26
		expect(user).to have(1).errors_on(:name)
	end

	it "is invalid when email is not present" do
		user.email = ""
		expect(user).to have(2).errors_on(:email)
	end

	it "is invalid when email format is invalid" do
		addresses = %w(user@foo,com user.org user@user@foo.com)
		addresses.each do |invalid_address|
			user.email = invalid_address
			expect(user).to have(1).errors_on(:email)
		end
	end

	it "is valid when email format is valid" do
		addresses = %w(UseR@eXampLE.org a_user+ANOther-user@user.user.user)
		addresses.each do |valid_address|
			user.email = valid_address
			expect(user).to be_valid
		end
	end

	it "is invalid when email address is already taken" do
		user_with_same_email = user.dup
		expect(user_with_same_email).to have(1).errors_on(:email)
	end

	it "is invalid when password is not present" do
		expect do
			create(:user, password: nil)
		end.to raise_error
	end

	it "is invalid when the password is too short" do
		expect do
			create(:user, password: "a" * 5)
		end.to raise_error
	end

	it "is valid when the password is 6 symbols long" do
		user.password = "a" * 6
		expect(user).to be_valid
	end

	it "is valid when the password is 25 symbols long" do
		user.password = "a" * 25
		expect(user).to be_valid
	end

	it "is invalid when the password is too long" do
		expect do
			create(:user, password: "a" * 26)
		end.to raise_error
	end

	it "is invalid when the daily limit is not present" do
		user.daily_limit = nil
		expect(user).to have(1).errors_on(:daily_limit)
	end

	it "is invalid when the daily limit is 0" do
		user.daily_limit = 0
		expect(user).to have(1).errors_on(:daily_limit)
	end

	it "is valid when the daily limit is 1" do
		user.daily_limit = 1
		expect(user).to be_valid
	end

	it "is valid when the daily limit is 100" do
		user.daily_limit = 100
		expect(user).to be_valid
	end

	it "is invalid when the daily limit is 101" do
		user.daily_limit = 101
		expect(user).to have(1).errors_on(:daily_limit)
	end

	context "successful repetitions percentage" do
		it "is 0 if no repetitions have been run today" do
			expect(user.stats_for_period(1.day)[:successful_repetitions_percentage]).to be_zero
		end
	end
end
