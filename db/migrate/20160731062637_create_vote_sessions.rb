class CreateVoteSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :vote_sessions do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.decimal :budget, precision: 10, scale: 2

      t.timestamps
    end
  end
end
