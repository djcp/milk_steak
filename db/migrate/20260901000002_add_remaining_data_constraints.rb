class AddRemainingDataConstraints < ActiveRecord::Migration[8.1]
  def up
    # A recipe is meant to have at most one featured image, but nothing
    # enforced it, so FeaturedImageChooser's pick was undefined when several
    # were flagged. Partial unique index: any number of non-featured images,
    # at most one featured.
    execute 'UPDATE images SET featured = false WHERE id NOT IN (
      SELECT MIN(id) FROM images WHERE featured = true GROUP BY recipe_id
    ) AND featured = true'
    add_index :images, :recipe_id, unique: true, where: 'featured = true',
      name: 'index_images_one_featured_per_recipe'

    # Deliberately NOT adding a unique index on
    # (recipe_id, section, position), which the audit suggested.
    # acts_as_list reorders by swapping positions across separate UPDATE
    # statements, so the intermediate state duplicates a position. Postgres
    # checks a unique *index* immediately; only a table CONSTRAINT can be
    # DEFERRABLE, and the expression this needs (COALESCE over the nullable
    # section) cannot be one. Adding it breaks move_lower/move_higher outright,
    # which is a worse outcome than the cosmetic ordering glitch it prevents.
    # Positions are still normalised here as a one-off tidy-up.
    deduplicate_positions

    # Legacy rows relied on a '' default plus NOT NULL, which let exactly one
    # blank username exist (and is why the views carry an armored_email
    # fallback). New rows must supply a real one.
    change_column_default :users, :username, from: '', to: nil

    # The model compares usernames and emails case-insensitively; without
    # functional indexes the database would still accept Alice@x.com alongside
    # alice@x.com.
    remove_index :users, :username, name: 'index_users_on_username'
    add_index :users, 'lower(username)', unique: true, name: 'index_users_on_lower_username'
    remove_index :users, :email, name: 'index_users_on_email'
    add_index :users, 'lower(email)', unique: true, name: 'index_users_on_lower_email'
  end

  def down
    remove_index :users, name: 'index_users_on_lower_email'
    add_index :users, :email, unique: true, name: 'index_users_on_email'
    remove_index :users, name: 'index_users_on_lower_username'
    add_index :users, :username, unique: true, name: 'index_users_on_username'
    change_column_default :users, :username, from: nil, to: ''
    remove_index :images, name: 'index_images_one_featured_per_recipe'
  end

  private

  def deduplicate_positions
    execute <<~SQL.squish
      UPDATE recipe_ingredients target
      SET position = renumbered.new_position
      FROM (
        SELECT id, ROW_NUMBER() OVER (
          PARTITION BY recipe_id, COALESCE(section, '')
          ORDER BY position NULLS LAST, id
        ) AS new_position
        FROM recipe_ingredients
      ) renumbered
      WHERE target.id = renumbered.id
        AND target.position IS DISTINCT FROM renumbered.new_position
    SQL
  end
end
