class AddFilenameToSeries < ActiveRecord::Migration[5.1]
  def change
    add_column :series, :filename, :text
  end
end
