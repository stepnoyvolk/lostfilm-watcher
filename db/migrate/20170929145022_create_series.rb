class CreateSeries < ActiveRecord::Migration[5.1]
  def change
    create_table :series do |t|
      t.integer :serial_id
      t.string :serial_name
      t.text :serie_name
      t.text :magnet
      t.integer :season
      t.integer :serie

      t.timestamps
    end
  end
end
