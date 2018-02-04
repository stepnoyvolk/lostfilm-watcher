class ChangeaboutShortInSerials < ActiveRecord::Migration[5.1]
  def change
    change_column :serials, :about_short, :text
    change_column :serials, :about_full, :text
    change_column :serials, :image, :text


  end
end
