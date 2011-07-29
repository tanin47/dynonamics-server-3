class AddAvgWaitingTime < ActiveRecord::Migration
  def self.up
    add_column :dyno_histories, :before_avg_waiting_time, :decimal, :precision => 17, :scale => 6,:default=>0
    add_column :dyno_histories, :before_avg_service_time, :decimal, :precision => 17, :scale => 6,:default=>0
    add_column :dyno_histories, :before_wanted_time, :decimal, :precision => 17, :scale => 6,:default=>0
    add_column :dyno_histories, :before_number_of_requests, :integer ,:default=>0
  end

  def self.down
  end
end
