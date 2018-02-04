class AddFilenameToSerials < ActiveRecord::Migration[5.1]
  def change
    add_column :serials, :filename, :text
  end
end
