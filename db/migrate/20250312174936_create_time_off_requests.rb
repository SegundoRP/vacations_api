class CreateTimeOffRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :time_off_requests do |t|
      t.integer :request_type, null: false
      t.integer :status, null: false, default: 0
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :reason
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
