require 'mysql2'

client = Mysql2::Client.new(:host => "localhost",
                             :username => "root",
                             :password => "Teresopolis_12",
                             :database => "sys")

def updating_peoples(client)
  peoples_ian = "SELECT * FROM people_ian"

  @peoples = @peoples ? @peoples : client.query(peoples_ian).to_a

  @peoples.each do |p|
    client.query("UPDATE people_ian SET last_name = '#{(p['last_name'] + 'updated').gsub(/(updated) \1/, '\1')}',
                  email = '#{p['email'].downcase}', email2 = '#{p['email2'].downcase}',
                  profession = '#{p['profession'].strip}' WHERE id = #{p['id']}")
  end
end

updating_peoples(client)