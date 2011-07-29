class TunerLogs < ActiveRecord::Migration
  def self.up
    create_table :tuner_logs, :force => true do |table|
      table.text  :data
      table.text  :error_message
      table.datetime     :created_time                   
    end
  end

  def self.down
    drop_table :tuner_logs
  end
end
