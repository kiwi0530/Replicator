class CreateRUsers < ActiveRecord::Migration
  def self.up
    create_table :r_users do |t|
      t.column :userset_id,:integer
      t.column :username,:string
      t.column :password,:string
      t.column :domain_id,:integer
      t.column :created_at,:datetime,:default=>'now()'      
    end
  end

  def self.down
    drop_table :r_users
  end
end
