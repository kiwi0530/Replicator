class RDomain < ActiveRecord::Base
  belongs_to :zone,:class_name=>'RZone',:foreign_key=>'zone_id'  
  has_many :users,:class_name=>'RUser',:foreign_key=>'domain_id'  
  has_many :resources,:class_name=>'RResource',:foreign_key=>'domain_id' 
  
  include LibReplicator::ModelMethods
  
  def self.create_or_update(obj)
    cur_obj=self.find :first,:conditions=>{:name=>obj.name}
    if cur_obj
      cur_obj.update_attributes obj.attributes
    else
      obj.save
    end
  end  
  
  def self.sync
    u=RUser.find :first
    domains=u.query [:user_name,:user_domain,:zone_name],{:user_type_name=>'= sysadmin'}
    domains.each do |d|
      next if d.user_domain =~ /[a-z]+/
      z=RZone.find :first,:conditions=>{:name=>d.zone_name}
      domain=RDomain.new :name=>d.user_domain,:zone_id=>z.id
      RDomain.create_or_update domain
    end
  end
end
