class ChangeLogColumn < ActiveRecord::Migration
  def self.up
    change_column :logs, :http_x_heroku_dyno_in_use, :integer
    change_column :logs, :http_x_heroku_queue_depth, :integer
  end

  def self.down
  end
end
