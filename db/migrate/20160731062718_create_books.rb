class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :item_id, uinque: true
      t.string :author
      t.string :publisher
      t.string :image
      t.decimal :price, precision: 10, scale: 2
      t.text :origin_url
      t.text :purchase_url

      t.timestamps
    end
  end
end
