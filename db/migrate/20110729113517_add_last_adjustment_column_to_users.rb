class AddLastAdjustmentColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_adjustment_time, :datetime
  end

  def self.down
    remove_column :users, :last_adjustment_time
  end
end
