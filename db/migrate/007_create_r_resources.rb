class CreateRResources < ActiveRecord::Migration
  def self.up
    create_table :r_resources do |t|
      t.column :name,:string
      t.column :address,:string
      t.column :downtime,:integer,:default=>0
      t.column :domain_id,:integer
      t.column :online,:boolean
      t.column :created_at,:datetime,:default=>'now()'      
      t.column :updated_at,:datetime
    end
  end

  def self.down
    drop_table :r_resources
  end
end
