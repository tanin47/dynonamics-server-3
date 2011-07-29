class UserNewField < ActiveRecord::Migration
  def self.up
    add_column :users, :max_dyno, :integer
    add_column :users, :avg_waiting_time, :decimal , :precision => 17, :scale => 6
  end

  def self.down
  end
end
