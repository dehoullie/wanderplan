class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :itinerary, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.integer :day
      t.string :part_of_day
      t.string :name
      t.string :description
      t.string :address
      t.references :category, null: false, foreign_key: true
      t.string :map_url
      t.integer :priority

      t.timestamps
    end
  end
end
