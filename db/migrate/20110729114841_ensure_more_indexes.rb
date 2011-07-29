class EnsureMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :logs, [:user_id,:status,:id]
    add_index :users, :dynonamics_key
  end

  def self.down
    remove_index :logs, [:user_id,:status,:id]
    remove_index :users, :dynonamics_key
  end
end
