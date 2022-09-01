def get_teacher(id, client)
  find_teacher = "SELECT first_name, middle_name, last_name
                  FROM teachers_ian t
                  WHERE t.id = #{id};
                 "

  query = client.query(find_teacher).to_a
  if query.count.zero?
    puts "Teacher with ID #{id} was not found!"
  else
    puts "Teacher: #{query[0]['first_name']} #{query[0]['middle_name']} #{query[0]['last_name']}"
  end
end

def get_subject_teachers(id, client)
  get_teachers_by_subject = "SELECT s.name AS subject, first_name, middle_name, last_name
                             FROM teachers_ian t
                             JOIN subjects_ian s USING(subjectId)
                             WHERE subjectId = #{id}"

  query = client.query(get_teachers_by_subject).to_a

  if query.count.zero?
    puts "No teacher with subject id #{id} "
  else
    puts "Subject: #{query[0]['subject']}\nTeachers:"

    query.each do |t|
      puts "#{t['first_name']}#{t['middle_name']} #{t['last_name']}"
    end
  end

end

def get_class_subjects(id, client)
  get_classes_by_subjects = "SELECT c.name AS class,
                             t.first_name,
                             SUBSTRING(middle_name, 1, 1) AS middle_name,
                             t.last_name,
                             s.name AS subject
                             FROM teachers_classes_ian tc
                             JOIN classes_ian c ON tc.class_id = c.id
                             JOIN teachers_ian t ON tc.teacher_id = t.id
                             JOIN subjects_ian s USING(subjectId)
                             WHERE c.id = #{id}"

  query = client.query(get_classes_by_subjects).to_a

  if query.count.zero?
    puts "The class id #{id} has no subject"
  else
    puts "Class: #{query[0]['class']}\nSubject: "
    query.each do |v|
      puts "#{v['subject']} (#{v['first_name']} #{v['middle_name']}. #{v['last_name']})"
    end
  end

end

def get_teachers_list_by_letter(letter, client)
  get_teachers_by_letter = "SELECT SUBSTRING(first_name, 1, 1) AS first_name_initial,
                            SUBSTRING(middle_name, 1, 1) AS middle_name_initial,
                            last_name,
                            s.name AS subject
                            FROM teachers_ian t
                            JOIN subjects_ian s USING(subjectId)
                            WHERE first_name REGEXP '#{letter}'
                            OR last_name REGEXP '#{letter}' "

  query = client.query(get_teachers_by_letter).to_a

  if query.count.zero?
    puts "No teacher with the letter #{letter} in the first or last name"
  else
    query.each do |t|
      puts "#{t['first_name_initial']}. #{t['middle_name_initial']}. #{t['last_name']} (#{t['subject']})"
    end
  end

end

def set_md5(digest, client)
  concat_teachers = "SELECT CONCAT (first_name,
                    middle_name,
                    last_name,
                    birth_date,
                    subjectId,
                    current_age) AS teacher
                    FROM teachers_ian"
  query = client.query(concat_teachers).to_a

  id = 0
  query.each do |t|
    client.query("UPDATE teachers_ian SET md5 = '#{digest.hexdigest(t.to_s)}' WHERE id = #{id += 1}")
  end
end

def get_class_info(class_id, client)
  get_class_info = "SELECT c.name AS name,
                    t.first_name, t.middle_name, t.last_name
                    FROM classes_ian c
                    JOIN teachers_ian t ON c.responsible_teacher_id = t.id
                    WHERE c.id = #{class_id}"

  get_involved_teachers = "SELECT t.first_name, t.middle_name, t.last_name
                           FROM teachers_classes_ian tc
                           JOIN teachers_ian t ON tc.teacher_id = t.id
                           JOIN classes_ian c ON tc.class_id = c.id
                           WHERE c.id = #{class_id}"

  query_info = client.query(get_class_info).to_a
  query_involved_teachers = client.query(get_involved_teachers).to_a

  if query_info.count.zero?
    puts "Class with ID #{class_id} was not found!"
  else
    puts "Class name: #{query_info[0]['name']}\nResponsible teacher: #{query_info[0]['first_name']} #{query_info[0]['middle_name']} #{query_info[0]['last_name']}"
    print "Involved teachers: "
    query_involved_teachers.each do |t|
      print "#{t['first_name']} #{t['middle_name']} #{t['last_name']}, "
    end
  end
end

def get_teachers_by_year(year, client)
  get_teacher_by_year = "SELECT first_name, middle_name, last_name
                         FROM teachers_ian
                         WHERE YEAR(birth_date) = #{year}"

  query = client.query(get_teacher_by_year).to_a

  if query.count.zero?
    puts "No teacher was born in the year #{year}"
  else
    print "Teachers born in #{year}: "
    query.each do |t|
      print "#{t['first_name']} #{t['middle_name']} #{t['last_name']}, "
    end
  end
end

def random_date(date_begin, date_end)
  rand(date_begin..date_end)
end

def random_last_names(n, client)
  query = "SELECT last_name FROM last_names"
  @last_names = @last_names ? @last_names : (client.query(query).to_a).map { |ln| ln['last_name']  }
  res = []
  n.times do |_|
    res << @last_names.sample
  end
  res
end

def random_first_name(n, client)
  query = "SELECT FirstName FROM male_names
                            UNION
                            SELECT names FROM female_names"

  @first_name = @first_name ? @first_name : (client.query(query).to_a).map { |fn| fn['FirstName'] }
  res = []
  n.times do |_|
    res << @first_name.sample
  end
  res
end

def generate_peoples(n, client)
  first_names = random_first_name(n, client)
  last_names = random_last_names(n, client)
  birth_dates = []
  n.times do
    birth_dates << random_date(Date.parse("1910-01-01"), Date.parse("2022-01-01")).to_s
  end
  people = []
  first_names.each_with_index do |fn, i|
    people << {"f_name"=>fn, "l_name"=>last_names[i], "birth_date"=>birth_dates[i]}
  end
  people.each do |people_|
    client.query("INSERT INTO random_people_ian (first_name, last_name, birth_date)
                   VALUES ('#{people_['f_name']}', '#{people_['l_name']}', '#{people_['birth_date']}')")
  end
  puts "#{n} people has been created!"
end