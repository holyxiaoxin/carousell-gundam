class CreateGundams < ActiveRecord::Migration
  def change
    create_table :gundams do |t|
      t.string :title
      t.integer :carousell_id
      t.text :description
      t.string :location_address
      t.string :location_name
      t.datetime :time_created
    end
  end
end
