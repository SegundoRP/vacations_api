class AddInformationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_reference :users, :leader, foreign_key: { to_table: :users }, null: true
  end
end
