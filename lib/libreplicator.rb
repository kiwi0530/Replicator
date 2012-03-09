path="#{File.expand_path(RAILS_ROOT)}/lib/jargon.jar"

if !ENV["CLASSPATH"]
  ENV["CLASSPATH"] = "."
end

if RUBY_PLATFORM =~/mswin32/
  ENV["JAVA_HOME"]=(/(.*)\\bin/.match ENV["PATH"].split(';').find {|i| i.match 'jdk'})[1]
  ENV["CLASSPATH"]+=File::PATH_SEPARATOR+path.split('/').join(File::ALT_SEPARATOR)
else
  ENV["CLASSPATH"]+=File::PATH_SEPARATOR+path
end
require 'rjb'
FileFactory=Rjb::import 'edu.sdsc.grid.io.FileFactory'
SRBAccount=Rjb::import 'edu.sdsc.grid.io.srb.SRBAccount'
SRBMetaDataSet=Rjb::import 'edu.sdsc.grid.io.srb.SRBMetaDataSet'
SRBFile=Rjb::import 'edu.sdsc.grid.io.srb.SRBFile'
SRBRandomAccessFile=Rjb::import 'edu.sdsc.grid.io.srb.SRBRandomAccessFile'
SRBFileSystem=Rjb::import 'edu.sdsc.grid.io.srb.SRBFileSystem'
MetaDataCondition=Rjb::import 'edu.sdsc.grid.io.MetaDataCondition'
MetaDataSet=Rjb::import 'edu.sdsc.grid.io.MetaDataSet'
MetaDataRecordList=Rjb::import 'edu.sdsc.grid.io.MetaDataRecordList'

module ActiveSupport
  module JSON #:nodoc:
    module Encoders #:nodoc:
      define_encoder Time do |time|
        time.strftime "%Y/%m/%d %H:%m:%S".to_json
      end      
    end
  end
end  

module LibReplicator
  module ModelMethods

  end
end