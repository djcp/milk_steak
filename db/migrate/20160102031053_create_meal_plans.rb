class CreateMealPlans < ActiveRecord::Migration
  def change
    create_table :meal_plans do |t|
      t.string :name, null: false
      t.string :description, limit: 8.kilobytes
    end
  end
end
