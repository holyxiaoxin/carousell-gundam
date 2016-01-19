class CreateWatchlists < ActiveRecord::Migration
  def change
    create_table :watchlists do |t|
      t.string :chat_id
    end
  end
end
