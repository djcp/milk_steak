class HardenSchemaConstraints < ActiveRecord::Migration[8.1]
  def up
    # No production deployment exists; dev/test databases are disposable, so
    # these cleanups run inline rather than as a separate backfill deploy.
    cleanup_unusable_rows

    # ── Foreign keys: match the models' `dependent: :destroy` intent ──
    # Every FK below defaulted to NO ACTION, which contradicts the models and
    # (for recipes -> users) broke Devise account cancellation outright.
    remove_foreign_key :recipes, :users
    remove_foreign_key :images, :recipes
    remove_foreign_key :recipe_ingredients, :recipes
    remove_foreign_key :recipe_ingredients, :ingredients

    # ── Widen legacy integer FK columns to match their bigint primary keys ──
    change_column :recipes, :user_id, :bigint
    change_column :images, :recipe_id, :bigint
    change_column :recipe_ingredients, :recipe_id, :bigint
    change_column :recipe_ingredients, :ingredient_id, :bigint
    change_column :taggings, :tag_id, :bigint
    change_column :taggings, :taggable_id, :bigint
    change_column :taggings, :tagger_id, :bigint

    # ai_classifier_runs.recipe_id stays nullable on purpose: runs outlive the
    # recipes they describe (FK is on_delete: :nullify).
    remove_foreign_key :ai_classifier_runs, :recipes
    change_column :ai_classifier_runs, :recipe_id, :bigint
    add_foreign_key :ai_classifier_runs, :recipes, on_delete: :nullify

    change_column_null :recipes, :user_id, false
    change_column_null :images, :recipe_id, false

    add_foreign_key :recipes, :users, on_delete: :cascade
    add_foreign_key :images, :recipes, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :recipes, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :ingredients, on_delete: :cascade

    # ── Ingredient names are lowercase-normalized in the model; enforce the
    # "one canonical row per name" invariant at the DB so no writer can bypass it.
    remove_index :ingredients, name: 'index_ingredients_on_name'
    add_index :ingredients, 'lower(name)', unique: true, name: 'index_ingredients_on_lower_name'

    # ── Domain constraints that were validation-only and bypassable via
    # update_column / insert_all / raw SQL ──
    add_check_constraint :recipes,
      "status IN ('draft','processing','processing_failed','review','published','rejected')",
      name: 'recipes_status_check'
    add_check_constraint :recipes,
      'octet_length(source_text) <= 51200',
      name: 'recipes_source_text_length_check'

    timestamp_columns.each { |table, column| change_column_null table, column, false }
  end

  def down
    timestamp_columns.each { |table, column| change_column_null table, column, true }

    remove_check_constraint :recipes, name: 'recipes_source_text_length_check'
    remove_check_constraint :recipes, name: 'recipes_status_check'

    remove_index :ingredients, name: 'index_ingredients_on_lower_name'
    add_index :ingredients, :name, unique: true, name: 'index_ingredients_on_name'

    remove_foreign_key :recipe_ingredients, :ingredients
    remove_foreign_key :recipe_ingredients, :recipes
    remove_foreign_key :images, :recipes
    remove_foreign_key :recipes, :users

    change_column_null :images, :recipe_id, true
    change_column_null :recipes, :user_id, true

    remove_foreign_key :ai_classifier_runs, :recipes
    change_column :ai_classifier_runs, :recipe_id, :integer
    add_foreign_key :ai_classifier_runs, :recipes, on_delete: :nullify

    change_column :taggings, :tagger_id, :integer
    change_column :taggings, :taggable_id, :integer
    change_column :taggings, :tag_id, :integer
    change_column :recipe_ingredients, :ingredient_id, :integer
    change_column :recipe_ingredients, :recipe_id, :integer
    change_column :images, :recipe_id, :integer
    change_column :recipes, :user_id, :integer

    add_foreign_key :recipe_ingredients, :ingredients
    add_foreign_key :recipe_ingredients, :recipes
    add_foreign_key :images, :recipes
    add_foreign_key :recipes, :users
  end

  private

  def timestamp_columns
    [
      %i[images created_at], %i[images updated_at],
      %i[ingredients created_at], %i[ingredients updated_at],
      %i[recipe_ingredients created_at], %i[recipe_ingredients updated_at],
      %i[recipes created_at], %i[recipes updated_at]
    ]
  end

  # An authorless recipe cannot be rendered (the show view and admin index both
  # reach through to user), and a parentless image is unreachable. Both are
  # artifacts of the missing NOT NULL, so drop them rather than invent an owner.
  def cleanup_unusable_rows
    execute 'DELETE FROM images WHERE recipe_id IS NULL'
    execute 'DELETE FROM recipes WHERE user_id IS NULL'

    timestamp_columns.each do |table, column|
      execute "UPDATE #{table} SET #{column} = NOW() WHERE #{column} IS NULL"
    end
  end
end
