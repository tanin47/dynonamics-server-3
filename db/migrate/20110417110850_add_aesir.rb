class AddAesir < ActiveRecord::Migration
  def self.up
    create_table :aesirs, :force => true do |t|
      t.string :username
      t.datetime :created_date
    end
  end

  def self.down
    drop_table :aesirs
  end
end
