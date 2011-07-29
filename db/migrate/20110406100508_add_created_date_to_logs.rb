class AddCreatedDateToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :created_date, :datetime,:default=>Time.now
  end

  def self.down
  end
end
