class CreateFixtures < ActiveRecord::Migration
  def self.up
    CustomReplicaMethod.create 
    StandardReplicaMethod.create 
    NtuReplicaMethod.create
    
    Policy.create :name=>'Custom',:desc=>"自行定義要複製過去的Resource清單",:replica_method_id=>1
    Policy.create :name=>'High',:desc=>"所有的Zone裡取所有Domain，複製2次",:zone=>100,:zonetype=>"percent",
      :domain=>100,:domaintype=>'percent',:resource=>2,:resourcetype=>"number",:replica_method_id=>2
    Policy.create :name=>'MediumHigh',:desc=>"所有的Zone裡取所有Domain，複製1次",:zone=>100,:zonetype=>"percent",
      :domain=>100,:domaintype=>'percent',:resource=>1,:resourcetype=>"number",:replica_method_id=>2
    Policy.create :name=>'Medium',:desc=>"所有的Zone裡取一半Domain，複製1次",:zone=>100,:zonetype=>"percent",
      :domain=>50,:domaintype=>'percent',:resource=>1,:resourcetype=>"number",:replica_method_id=>2
    Policy.create :name=>'MediumLow',:desc=>"取1個Zone的一半Domain，複製1次",:zone=>1,:zonetype=>"number",
      :domain=>50,:domaintype=>'percent',:resource=>1,:resourcetype=>"number",:replica_method_id=>2
    Policy.create :name=>'Low',:desc=>"取1個Zone的1個Domain，複製1次",:zone=>1,:zonetype=>"number",:domain=>1,
      :domaintype=>'number',:resource=>1,:resourcetype=>"number",:replica_method_id=>2

    RZone.create :name=>'Hsinchu_UNIGRID',:host=>'140.126.130.79',:port=>5544
    RDomain.create :name=>'CHU',:zone_id=>1
    RUser.create :username=>'srbadmin',:password=>'srbadmin',:domain_id=>1

    RFile.create :name=>'inQ.exe',:path=>'/Hsinchu_UNIGRID/home/srbadmin.CHU',:user_id=>1,:policy_id=>6
    RFile.create :name=>'pietty0327.exe',:path=>'/Hsinchu_UNIGRID/home/srbadmin.CHU',:user_id=>1,:policy_id=>4
    RFile.create :name=>'test.txt',:path=>'/Hsinchu_UNIGRID/home/srbadmin.CHU',:user_id=>1,:policy_id=>3
    

  end

  def self.down
  end
end
