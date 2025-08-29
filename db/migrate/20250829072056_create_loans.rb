class CreateLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :loans do |t|
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :borrowed_on
      t.date :returned_on
      t.date :due_date
      t.string :status

      t.timestamps
    end
  end
end
