class CreateCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :carts do |t|
      t.belongs_to :vote_session, index: true, foreign_key: true

      t.timestamps
    end
  end
end
