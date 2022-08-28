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