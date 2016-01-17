class CreateNotifiedGundams < ActiveRecord::Migration
  def change
    create_table :notified_gundams do |t|
      t.integer :carousell_id
    end
  end
end
