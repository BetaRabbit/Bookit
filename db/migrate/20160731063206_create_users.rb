class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.belongs_to :vote, foreign_key: true
      t.string :name
      t.string :email
      t.string :ip

      t.timestamps
    end
  end
end
