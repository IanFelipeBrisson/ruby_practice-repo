require 'mysql2'

client = Mysql2::Client.new(:host => "localhost",
                             :username => "root",
                             :password => "Teresopolis_12",
                             :database => "sys")

def updating_peoples(client)
  peoples_ian = "SELECT * FROM people_ian"

  query = client.query(peoples_ian).to_a

  query.each do |p|
    client.query("UPDATE people_ian SET last_name = CONCAT(last_name, ' updated') WHERE id = #{p[id]}")
    client.query("UPDATE people_ian SET email = '#{p['email'].downcase}', email2 = '#{p['email2'].downcase}' WHERE id = #{p['id']}")
    client.query("UPDATE people_ian SET profession = '#{p['profession'].strip}' WHERE id = #{p['id']}")
  end
end

updating_peoples(client)