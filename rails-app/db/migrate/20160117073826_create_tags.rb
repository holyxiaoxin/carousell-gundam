class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :watchlist, index: true, foreign_key: true
      t.string :tag
    end
  end
end
