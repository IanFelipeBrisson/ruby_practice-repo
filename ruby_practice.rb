require "mysql2"
require "dotenv/load"
require_relative 'methods'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

#get_teacher(2, client)

#get_subject_teachers(2, client)

#get_class_subjects(1, client)

get_teachers_list_by_letter("a", client)

client.close