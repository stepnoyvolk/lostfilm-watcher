class AddMagnetToTorrents < ActiveRecord::Migration[5.1]
  def change
    add_column :serials, :magnet, :text
  end
end
