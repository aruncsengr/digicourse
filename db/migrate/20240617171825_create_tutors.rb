class CreateTutors < ActiveRecord::Migration[7.0]
  def change
    create_table :tutors do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email, index: { unique: true }
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
