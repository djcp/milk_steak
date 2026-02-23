class AddUsernameAndApprovedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string, null: false, default: ''
    add_column :users, :approved, :boolean, default: false, null: false
    add_index  :users, :username, unique: true
  end
end
