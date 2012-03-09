class CreateRDomains < ActiveRecord::Migration
  def self.up
    create_table :r_domains do |t|
      t.column :name,:string
      t.column :zone_id,:integer
      t.column :created_at,:datetime,:default=>'now()'      
    end
  end

  def self.down
    drop_table :r_domains
  end
end
