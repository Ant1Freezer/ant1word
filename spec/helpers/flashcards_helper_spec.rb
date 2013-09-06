# coding: UTF-8

require 'spec_helper'

describe FlashcardsHelper do
	describe "first_line" do
		it "should truncate a given string" do
			expect(first_line("foo\r\n\r\nbar")).to eq "foo..."
		end

		it "should not add an ellipsis if there's only one line in the parameter" do
			expect(first_line("foo")).to eq "foo"
		end
	end
end