require "mysql2"
require "dotenv/load"
require "digest"
require_relative 'methods'

md5 = Digest::MD5.new
client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

#get_teacher(2, client)

#get_subject_teachers(2, client)

#get_class_subjects(1, client)

#get_teachers_list_by_letter("a", client)

#set_md5(md5, client)

#get_class_info(4, client)

#get_teachers_by_year(1959, client)

client.close