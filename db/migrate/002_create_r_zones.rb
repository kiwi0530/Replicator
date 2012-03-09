class CreateRZones < ActiveRecord::Migration
  def self.up
    create_table :r_zones do |t|
      t.column :name,:string
      t.column :host,:string
      t.column :port,:integer
      t.column :created_at,:datetime,:default=>'now()'      
    end
  end

  def self.down
    drop_table :r_zones
  end
end
