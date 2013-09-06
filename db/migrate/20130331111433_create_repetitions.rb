class CreateRepetitions < ActiveRecord::Migration
  def change
    create_table :repetitions do |t|
      t.references :flashcard
      t.date :planned_date
      t.date :actual_date
      t.boolean :run, :default => false
      t.boolean :successful
      t.timestamps
    end
  end
end
