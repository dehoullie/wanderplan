class CreateCategoriesPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :categories_preferences do |t|
      t.references :category, null: false, foreign_key: true
      t.references :preference, null: false, foreign_key: true

      t.timestamps
    end
  end
end
