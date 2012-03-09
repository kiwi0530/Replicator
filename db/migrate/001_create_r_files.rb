class CreateRFiles < ActiveRecord::Migration
  def self.up
    create_table :r_files do |t|
      t.column :path,:text
      t.column :name,:string
      t.column :user_id,:integer
      t.column :policy_id,:integer
      t.column :created_at,:datetime,:default=>'now()'
    end
  end

  def self.down
    drop_table :r_files
  end
end
