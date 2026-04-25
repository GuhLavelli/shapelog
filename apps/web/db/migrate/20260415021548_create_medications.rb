class CreateMedications < ActiveRecord::Migration[8.1]
  def change
    create_table :medications do |t|
      t.references :user,                null: false, foreign_key: true
      t.string  :name,                   null: false
      t.date    :taken_on,               null: false
      t.decimal :dosage,                 null: false, precision: 5, scale: 2
      t.string  :administration_site,    null: true
      t.text    :side_effects,           null: true
      t.text    :notes,                  null: true

      t.timestamps
    end

    add_index :medications, [:user_id, :taken_on]
  end
end
