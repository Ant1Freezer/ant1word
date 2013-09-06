include FlashcardsHelper


# Миграция добавляет поле learned_on, которое нужно для сбора статистики:
# чтобы узнать, когда был последний повтор карточки, не нужно писать сложных запросов.
class AddLearnedOnToFlashcards < ActiveRecord::Migration
  def change
    add_column :flashcards, :learned_on, :date
    migrate_learned_dates
  end
end
