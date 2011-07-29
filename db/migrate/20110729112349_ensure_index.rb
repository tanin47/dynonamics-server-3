class EnsureIndex < ActiveRecord::Migration
  def self.up
    add_index :logs, [:user_id,:status]
    add_index :users, :status
    add_index :dyno_histories, [:created_time,:user_id]
  end

  def self.down
    remove_index :logs, [:user_id,:status]
    remove_index :users, :status
    remove_index :dyno_histories, [:created_time,:user_id]
  end
end
