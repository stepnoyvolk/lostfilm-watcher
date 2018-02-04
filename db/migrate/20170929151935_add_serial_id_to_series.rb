class AddSerialIdToSeries < ActiveRecord::Migration[5.1]
  def change
    add_index :series, :serial_id
  end
end
