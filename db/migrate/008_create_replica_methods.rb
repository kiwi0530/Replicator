class CreateReplicaMethods < ActiveRecord::Migration
  def self.up
    create_table :replica_methods do |t|
      t.column :type,:string
    end
  end

  def self.down
    drop_table :replica_methods
  end
end
