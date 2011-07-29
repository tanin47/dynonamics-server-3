class ChangeLog < ActiveRecord::Migration
  def self.up
    remove_column :logs, :start_time
    remove_column :logs, :wait_time
    remove_column :logs, :process_time
    
    add_column :logs, :http_x_request_start, :decimal, :precision => 17, :scale => 6
    add_column :logs, :rails_start, :decimal,:precision => 17, :scale => 6
    add_column :logs, :rails_end, :decimal,:precision => 17, :scale => 6
    add_column :logs, :http_x_heroku_queue_wait_time, :decimal,:precision => 17, :scale => 6
    add_column :logs, :http_x_heroku_dyno_in_use, :decimal,:precision => 17, :scale => 6
    add_column :logs, :http_x_heroku_queue_depth, :decimal,:precision => 17, :scale => 6

  end

  def self.down
  end
end
