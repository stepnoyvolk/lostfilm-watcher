class AddDownloadedToSeries < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :downloaded, :boolean
  end
end
