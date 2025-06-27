class CreateUsersPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :users_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :preference, null: false, foreign_key: true
      t.string :title
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
