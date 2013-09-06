# coding: UTF-8

require 'spec_helper'

describe ApplicationHelper do
	describe "full_title" do
		it "should include both the page title and the base title" do
			full_title("foo").should == "foo &mdash; Вордхаб"
		end

		it "should not include an em dash when the page title is not provided or blank" do
			full_title.should_not =~ /\&mdash;/
			full_title("  ").should_not =~ /\&mdash;/
		end
	end


end