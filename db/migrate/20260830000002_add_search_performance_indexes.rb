class AddSearchPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    enable_extension :pg_trgm

    add_index :recipes, 'lower(name) gin_trgm_ops', name: 'index_recipes_on_lower_name_trgm', using: :gin
    add_index :ingredients, 'lower(name) gin_trgm_ops', name: 'index_ingredients_on_lower_name_trgm', using: :gin
    add_index :users, 'username gin_trgm_ops', name: 'index_users_on_username_trgm', using: :gin

    add_index :recipes, [:user_id, :status]
    add_index :recipes, [:status, :created_at]
  end
end
