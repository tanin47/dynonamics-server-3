class AddMinimumDyno < ActiveRecord::Migration
  def self.up
    add_column :users, :min_dyno, :integer, :null=>false,:default=>1
    add_column :users, :max_worker, :integer, :null=>false,:default=>5
    add_column :users, :min_worker, :integer, :null=>false,:default=>0
  end

  def self.down
  end
end
