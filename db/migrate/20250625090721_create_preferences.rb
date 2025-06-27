class CreatePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :preferences do |t|
      t.references :city, null: false, foreign_key: true
      t.references :budget, null: false, foreign_key: true
      t.integer :max_days
      t.string :slug

      t.timestamps
    end
  end
end
