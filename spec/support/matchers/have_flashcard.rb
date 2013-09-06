# coding: UTF-8

RSpec::Matchers.define :have_flashcard do |flashcard|
	match do |actual|
		actual.has_link?(flashcard.front_text,
			href: edit_flashcard_path(flashcard))
	end

	failure_message_for_should do |actual|
		"expected to have the specified flashcard on the page"
	end

	failure_message_for_should_not do |actual|
		"expected not to have the specified flashcard on the page"
	end

	description do
		"have a flashcard"
	end
end