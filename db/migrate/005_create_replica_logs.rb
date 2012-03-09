class CreateReplicaLogs < ActiveRecord::Migration
  def self.up
    create_table :replica_logs do |t|
      t.column :file_id,:integer
      t.column :action, :string
      t.column :replica_number, :integer
      t.column :resource,:string
      t.column :success, :boolean
      t.column :created_at,:datetime,:default=>'now()'
    end
  end

  def self.down
    drop_table :replica_logs
  end
end
