class CreateSerials < ActiveRecord::Migration[5.1]
  def change
    create_table :serials do |t|
      t.string :name
      t.string :image
      t.string :serial_link
      t.string :about_short
      t.string :about_full
      t.boolean :tracked

      t.timestamps
    end
  end
end
