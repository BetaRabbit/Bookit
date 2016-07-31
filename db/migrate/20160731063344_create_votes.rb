class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.belongs_to :book, index: true, foreign_key: true
      t.belongs_to :vote_session, index: true, foreign_key: true
      t.string :voter

      t.timestamps
    end
  end
end
