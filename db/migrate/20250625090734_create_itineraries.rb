class CreateItineraries < ActiveRecord::Migration[7.1]
  def change
    create_table :itineraries do |t|
      t.references :preference, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
