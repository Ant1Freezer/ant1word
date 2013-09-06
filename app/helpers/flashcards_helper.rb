# encoding: utf-8

module FlashcardsHelper

	# Без этой строчки RSpec ругается, что не знает метода truncate.
	include ActionView::Helpers::TextHelper

	def first_line(string)
		eol = string.index("\r")
		return string if eol.nil?
		return truncate(string, length: eol + 3)
	end


	# Странно, что этот метод, необходимый для миграции, живёт в хелперах, но не знаю, куда его правильнее засунуть.
	def migrate_learned_dates
		repetitions_for_learned_flashcards = Flashcard.unscoped do
			Flashcard.learned.joins(:repetitions).select("flashcards.id AS id, repetitions.actual_date AS actual_date").order("actual_date DESC")
		end
    ids = []
    repetitions_for_learned_flashcards.each do |r|
    	id = r.id.to_i
      if !ids.include?(id)
        ids += [id]
        flashcard = Flashcard.find(id)
        flashcard.learned_on = r.actual_date
        flashcard.save!
      end
    end
	end
end
