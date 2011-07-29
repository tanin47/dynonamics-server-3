class CallbackUrlAdded < ActiveRecord::Migration
  def self.up
    add_column :users, :callback_url, :string
    add_column :users, :plan, :string
  end

  def self.down
    remove_column :users, :callback_url
    remove_column :users, :plan
  end
end
