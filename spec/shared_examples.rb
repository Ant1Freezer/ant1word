require 'spec_helper'

shared_examples "restricted pages" do
	it "sets a flash[:error] message" do
		expect(flash.to_hash).to_not eq({})
	end

	it "redirects to the home page" do
		expect(response).to redirect_to root_url
	end
end