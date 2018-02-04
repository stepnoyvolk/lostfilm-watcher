class AddTorrentStatusToSeries < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :download_status, :string
  end
end
