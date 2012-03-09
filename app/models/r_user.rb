class RUser < ActiveRecord::Base
  #assoc 
  belongs_to :domain,:class_name=>'RDomain',:foreign_key=>'domain_id'  
  has_many :files,:class_name=>'RFile',:foreign_key=>'user_id'    
  attr_reader :account,:filesystem  
  
  #
  def self.create_or_update(obj)
    cur_obj=self.find :first,:conditions=>{:userset_id=>obj.userset_id}
    if cur_obj
      cur_obj.update_attributes obj.attributes
    else
      obj.save
    end
  end    
  
  def self.sync
    Userset.find_all.each do |u|
      domain=RDomain.find_by_name u.domain
      user=RUser.new :username=>u.username,:password=>u.userpw,:domain_id=>domain.id,:userset_id=>u.userid
      RUser.create_or_update user
    end
  end  
  
  def zone
    self.domain.zone
  end

  def connect(force=false)
    #return if connected? && !force
    @account=SRBAccount.new zone.host,zone.port,self.username,self.password,"",self.domain.name,"",zone.name
    @filesystem=SRBFileSystem.new(self.account)
    logger.info "Connect #{zone.host},#{zone.port},#{username},#{domain.name}"
    @filesystem.isConnected
  end
  
  def connected?
    # TODO check socket broken
    @filesystem && filesystem.isConnected
  end
  
  def disconnect
    @filesystem.close
  end
  
  def query(selects=[],conditions={})
    connect if !connected?
    return nil if selects.size <=0
    tokens={
      "between"=>MetaDataCondition.BETWEEN,
      "="=>MetaDataCondition.EQUAL,
      ">="=>MetaDataCondition.GREATER_OR_EQUAL,
      ">"=>MetaDataCondition.GREATER_THAN,
      "in"=>MetaDataCondition.IN ,
      "<="=>MetaDataCondition.LESS_OR_EQUAL ,
      "<"=>MetaDataCondition.LESS_THAN ,
      "like"=>MetaDataCondition.LIKE,
      #"not between"=>MetaDataCondition.NOT_BETWEEN,
      "!="=>MetaDataCondition.NOT_EQUAL,
      #"not in"=>MetaDataCondition.NOT_IN,
      #"not like"=>MetaDataCondition.NOT_LIKE,
    }
    conds=conditions.collect { |c,v|
      token=v.split(' ')[0]
      value=v.split(' ')[1]
      logger.debug "Condition #{SRBMetaDataSet.send(c.to_s.upcase)}, #{token}, #{value.strip}"
      MetaDataSet.newCondition(SRBMetaDataSet.send(c.to_s.upcase),tokens[token],value.strip)
    }
    conds.compact!
    conds=nil if conds.size<=0
    sels=selects.collect{|s| MetaDataSet.newSelection(SRBMetaDataSet.send(s.to_s.upcase))}
    logger.debug "Query #{sels.inspect},#{conds.inspect} "  
    
    #begin
      result_objs=@filesystem.query conds,sels
    #rescue
    #  connect(true)
    #  retry
    #end    
    if !result_objs
      logger.info "Query #{selects.inspect},#{conditions.inspect} got no result!"
      return [] 
    end  
    logger.info "Query #{selects.inspect},#{conditions.inspect} got #{result_objs.size} record"
    result_objs.collect do |obj|
      result=Object.new
      data={}
      selects.each{|s| data[s]=obj.getValue(SRBMetaDataSet.send(s.to_s.upcase)).toString}
      result.instance_variable_set "@data",data
      def result.method_missing(method,*args)
        @data[method]
      end
      result
    end
  end
  
  
  def srb_files
    connect if !connected?
    self.files.collect do |f|
      f.file
    end
  end
  
  def update_resources
    connect if !connected?    
  end
  
end