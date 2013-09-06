# coding: UTF-8

RSpec::Matchers.define :have_deleted_flashcard do |flashcard|
	match do |actual|
		actual.has_button?("Восстановить") &&
			(flashcard.nil? || 
			actual.has_selector?("label", text: first_line(flashcard.front_text)))
	end

	failure_message_for_should do |actual|
		"expected to have a deleted flashcard on the page"
	end

	failure_message_for_should_not do |actual|
		"expected not to have deleted flashcards on the page"
	end

	description do
		"have an undelete form"
	end
end