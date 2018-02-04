class AddTorrentIdToSeries < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :torrnetid, :string
    add_column :series, :torrent_status, :string
  end
end
