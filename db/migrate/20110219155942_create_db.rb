class CreateDb < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :dynonamics_key
      t.string :username
      t.string :api_key
      t.string :status
      t.string :app_name
      t.datetime :created_date
    end
    
    create_table :logs, :force => true do |t|
      t.decimal :start_time, :precision => 17, :scale => 6
      t.decimal :wait_time, :precision => 17, :scale => 6
      t.decimal :process_time, :precision => 17, :scale => 6
      t.decimal :incoming_time, :precision => 17, :scale => 6
      t.integer :user_id
    end
    
    create_table :dyno_histories, :force => true do |t|
      t.integer :before_number
      t.integer :after_number
      t.datetime :created_time
      t.integer :user_id
    end
    
    create_table :worker_histories, :force => true do |t|
      t.integer :before_number
      t.integer :after_number
      t.datetime :created_time
      t.integer :user_id
    end
  end

  def self.down
  end
end
