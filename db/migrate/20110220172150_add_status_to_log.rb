class AddStatusToLog < ActiveRecord::Migration
  def self.up
    add_column :logs, :status, :string
  end

  def self.down
  end
end
