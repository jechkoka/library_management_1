class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.text :description
      t.string :isbn
      t.integer :published_year
      t.string :category
      t.boolean :available

      t.timestamps
    end
  end
end
