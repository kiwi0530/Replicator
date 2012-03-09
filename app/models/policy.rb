class Policy < ActiveRecord::Base
  has_many :files,:class_name=>'RFile',:foreign_key=>'policy_id'
  belongs_to :replica_method
  
end



