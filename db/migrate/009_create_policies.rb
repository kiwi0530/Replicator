class CreatePolicies < ActiveRecord::Migration
  def self.up
    create_table :policies do |t|
      t.column :type,:string
      t.column :name,:string
      t.column :desc,:text
      t.column :zone,:integer
      t.column :zonetype,:string
      t.column :domain,:integer
      t.column :domaintype,:string
      t.column :resource,:integer
      t.column :resourcetype,:string
      t.column :resource_list,:text
      t.column :replica_method_id,:integer
    end
  end

  def self.down
    drop_table :policies
  end
end
