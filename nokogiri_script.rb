require 'mysql2'
require 'dotenv/load'
require 'nokogiri'
require 'open-uri'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")
document = Nokogiri::HTML(URI.open("https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html").read)

document.search('table tbody tr').each do |row|
  cells = row.search('td').map { |e| e.text.gsub(/,/, '') }

  query = "INSERT INTO covid_test_ian
    (week,
    total_spec_tested_including_age_unkown,
    total_percent_pos_including_age_unkown,
    0_to_4_yrs_spec_tested,
    0_to_4_yrs_percent_pos,
    5_to_17_yrs_spec_tested,
    5_to_17_yrs_percent_pos,
    18_to_49_yrs_spec_tested,
    18_to_49_yrs_percent_pos,
    50_to_64_spec_tested,
    50_to_64_percent_pos,
    65_plus_yrs_spec_tested,
    65_plus_yrs_percent_pos)
    VALUES (#{cells[0]}, #{cells[1]}, #{cells[2]}, #{cells[3]}, #{cells[4]},
        #{cells[5]}, #{cells[6]}, #{cells[7]}, #{cells[8]}, #{cells[9]},
        #{cells[10]}, #{cells[11]}, #{cells[12]})"
  client.query(query)
end