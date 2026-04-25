class CreateMounjaroApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :mounjaro_applications do |t|
      t.references :user,             null: false, foreign_key: true
      t.date    :application_date,    null: false
      t.decimal :dose,                null: false, precision: 4, scale: 2
      t.string  :application_site,    null: true
      t.text    :side_effects,        null: true
      t.text    :notes,               null: true

      t.timestamps
    end

    add_index :mounjaro_applications, [:user_id, :application_date]
  end
end
