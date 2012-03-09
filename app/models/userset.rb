class Userset < ActiveRecord::Base
  establish_connection "ndhu_development"
  set_table_name "userset"
  set_primary_key "userid"
end