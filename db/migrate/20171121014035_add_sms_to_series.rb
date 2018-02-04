class AddSmsToSeries < ActiveRecord::Migration[5.1]
  def change
	add_column :series, :sms, :boolean
  end
end
