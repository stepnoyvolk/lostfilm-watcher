json.extract! serial, :id, :name, :image, :serial_link, :about_short, :about_full, :tracked, :created_at, :updated_at
json.url serial_url(serial, format: :json)
