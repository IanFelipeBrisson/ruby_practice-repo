require 'mysql2'
require 'dotenv/load'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

def creating_table(client)
  begin
    create_table = "CREATE TABLE montana_public_district_report_card_uniq_dist_ian (
                    id INT NOT NULL AUTO_INCREMENT,
                    name VARCHAR(100),
                    clean_name VARCHAR(100),
                    address VARCHAR(150),
                    city VARCHAR(50),
                    state VARCHAR(30),
                    zip INT,
                    UNIQUE (name, clean_name, address, city, state, zip),
                    PRIMARY KEY (id)
                    );"
    client.query(create_table)
  rescue Mysql2::Error => e
    puts e
  end
end

def inserting_unique_districts(client)
  inserting = "INSERT INTO montana_public_district_report_card_uniq_dist_ian (name, address, city, state, zip)
               SELECT DISTINCT school_name, address, city, state, zip FROM montana_public_district_report_card"

  client.query(inserting)
end

def cleaning_name(client)
  q = "SELECT * FROM montana_public_district_report_card_uniq_dist_ian"
  query = client.query(q).to_a

  query.each do |row|
    client.query("UPDATE montana_public_district_report_card_uniq_dist_ian
                  SET clean_name = '#{(row['name'] + ' District').gsub(/(Elem|El)/, 'Elementary School').
      gsub(/(H S|HS|Dist H S)/, 'High School').
      gsub(/Schls|Schools/, 'School').
      gsub(/K-12|Public|School K-12/, 'Public School').
      gsub(/(\w+) \1/, '\1')}'
      WHERE id = #{row['id']}")
  end
end