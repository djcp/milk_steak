class CleanupLegacyColumnsAndAddConstraints < ActiveRecord::Migration[8.0]
  def change
    # Drop legacy Paperclip columns from images
    remove_column :images, :image_file_name, :string
    remove_column :images, :image_content_type, :string
    remove_column :images, :image_file_size, :integer
    remove_column :images, :image_updated_at, :datetime

    # Add missing index
    add_index :images, :recipe_id

    # Add foreign key constraints
    add_foreign_key :images, :recipes
    add_foreign_key :recipe_ingredients, :recipes
    add_foreign_key :recipe_ingredients, :ingredients
    add_foreign_key :recipes, :users
  end
end
