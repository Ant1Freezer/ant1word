class AddDeletedToFlashcards < ActiveRecord::Migration
  def change
    add_column :flashcards, :deleted, :boolean, :default => false
  end
end
