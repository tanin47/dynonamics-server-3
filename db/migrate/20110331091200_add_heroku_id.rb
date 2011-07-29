class AddHerokuId < ActiveRecord::Migration
  def self.up
    add_column :users, :heroku_id, :string
  end

  def self.down
  end
end
