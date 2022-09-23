require 'mysql2'
require 'dotenv/load'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

def get_candidate_office_names(client)
  query = "SELECT id, candidate_office_name, clean_name
           FROM hle_dev_test_ian"

  @names = @names ? @names : client.query(query).to_a
end

def reformat_names(client)
  candidate_names = get_candidate_office_names(client)

  candidate_names.each do |n|
    id = n['id']
    names = n['candidate_office_name']
    clean_name = n['clean_name'].to_s

    #Twp" => "Township"
    #"Hwy" => "Highway"
    #"Highway highway" and "Hwy hwy" become "Highway"
    clean_name = clean_name.gsub(/[T|t]wp/, 'Township').
      gsub(/[H|h]wy/, 'Highway').
      gsub(/Highway highway|Hwy hwy/, 'Highway')

    #clean repeated words
    clean_name = clean_name.gsub(/(\w.+?) \1/i, '\1')

    #Lowercase all words, unless they come after a slash or after a comma.
    if names.match(/[\/,]/)
      lowercase_words = names.downcase.match(/(.+?)(?<=[\/,])/).to_s
      lowercase_words[-1] = ''
    else
      lowercase_words = names.downcase
    end
    client.query("UPDATE hle_dev_test_ian SET clean_name = \"#{lowercase_words}\" WHERE id = #{id}")


    #Anything after a slash gets moved to the front of the name and remains capitalized.
    if names.include?("/") && !names.include?(",")
      move_word = names.gsub(/(.*)(?=\/)\/(.*)/, '\2 ')
      client.query("UPDATE hle_dev_test_ian SET clean_name = \"#{(move_word + clean_name).gsub(/(\w.+?) \1/i, '\1')}\" WHERE id = #{id}")
    end


    #Anything after a comma gets put in parentheses.
    if names.include?(",") && names.include?("/")
      a3 = '\3'
      a2 = '\2'
      words_after_comma = names.gsub(/(.*)(?=,),\s?(.*)(?=\/)(.*)/, "#{a3} #{$1.downcase.chop} (#{a2})").gsub(/(\/)/, '')
      client.query("UPDATE hle_dev_test_ian SET clean_name = \"#{words_after_comma}\" WHERE id = #{id}")
    elsif names.include?(",") && !names.include?("/")
      words_after_comma = names.gsub(/(?<=,)\s(\w.+)/, '(\1)').gsub(/(\w.+),/, '')
      client.query("UPDATE hle_dev_test_ian SET clean_name = \"#{clean_name} #{words_after_comma}\" WHERE id = #{id}")
    end


    #County Clerk/Recorder/DeKalb County becomes ‘DeKalb County clerk and recorder’
    if names.match(/County Clerk\/Recorder\/DeKalb County/)
      new_format = names.gsub(/(\w+)\s.(\w+)\/.(\w+)\/(DeKalb).*/, '\4 \1 c\2 and r\3')
      client.query("UPDATE hle_dev_test_ian SET clean_name = '#{new_format}' WHERE id = #{id}")
    end


    #Delete any periods. So, "Something Township." becomes "something township" -- no period.
    if clean_name.match(/\./)
      client.query("UPDATE hle_dev_test_ian SET clean_name = \"#{clean_name.gsub(/\./, '')}\" WHERE id = #{id}")
    end


    #It puts the following sentence in the sentence field: "The candidate is running for the [CLEAN_NAME] office
    client.query("UPDATE hle_dev_test_ian SET sentence = \"The candidate is running for the #{clean_name} office.\" WHERE id = #{id}")
  end

end

reformat_names(client)
