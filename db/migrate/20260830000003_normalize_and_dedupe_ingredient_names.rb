class NormalizeAndDedupeIngredientNames < ActiveRecord::Migration[8.1]
  def up
    # Normalize every ingredient name to its canonical (lowercase, trimmed)
    # form so recipe forms can create-or-match against one row per name.
    execute "UPDATE ingredients SET name = lower(btrim(name))"

    # Collapse case-insensitive name collisions that the normalization above
    # created (e.g. "Tomato" and "tomato"). The earliest row wins and keeps
    # its notes/url; recipe_ingredients rows are repointed before the losers
    # are deleted. This step is a one-way data migration.
    execute <<~SQL
      WITH dups AS (
        SELECT id,
               MIN(id) OVER (PARTITION BY lower(name)) AS keeper_id
        FROM ingredients
      )
      UPDATE recipe_ingredients
      SET ingredient_id = dups.keeper_id
      FROM dups
      WHERE recipe_ingredients.ingredient_id = dups.id
        AND dups.keeper_id <> dups.id
    SQL

    # Keep the earliest row per name; delete the rest (already repointed above).
    execute <<~SQL
      DELETE FROM ingredients AS loser
      USING ingredients AS keeper
      WHERE loser.name = keeper.name
        AND loser.id > keeper.id
    SQL

    # Replace the existing (non-unique) index with a unique one so the
    # database itself enforces one canonical row per ingredient name.
    remove_index :ingredients, :name, if_exists: true
    add_index :ingredients, :name, unique: true, if_not_exists: true
  end

  def down
    remove_index :ingredients, :name
  end
end