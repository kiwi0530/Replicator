class ReplicaLog < ActiveRecord::Base
  belongs_to :file,:class_name=>'RFile',:foreign_key=>:file_id
  
  
  def before_save
    self.created_at=Time.now
  end
end
