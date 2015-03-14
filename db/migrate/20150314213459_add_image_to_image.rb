class AddImageToImage < ActiveRecord::Migration
  def change
    remove_column :images, :filepicker_url
    add_attachment :images, :image
  end
end
