class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, :limit => 25
      t.string :email, :limit => 100
      t.string :hashed_password, :limit => 40
      t.string :salt, :limit => 40
      t.boolean :is_admin, :default => false
      t.integer :daily_limit, :default => 10
      t.timestamps
    end
  end
end
