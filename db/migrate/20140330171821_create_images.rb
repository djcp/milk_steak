class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :filepicker_url
      t.string :caption, limit: 1.kilobyte
      t.belongs_to :recipe
      t.boolean :featured, default: false

      t.timestamps
    end
  end
end
