class CreateFlashcards < ActiveRecord::Migration
  def change
    create_table :flashcards do |t|
      t.references :user
      t.text :front_text
      t.text :back_text
      t.integer :consecutive_successful_repetitions, :default => 0
      t.timestamps
    end
  end
end
