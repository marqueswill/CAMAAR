class ImportMembersService
  def self.call(members)
    members.each do |data|
      db_subject_class = SubjectClass.find_by(
        { subject: data['code'],
          code: data['classCode'],
          semester: data['semester'] }
      )

      unless db_subject_class
        @errors << %(#{data['code']}-#{data['classCode']}-#{data['semester']} Turma não foi encontrada)
        next
      end

      db_teacher = Teacher.find_by({ registration: data['docente']['usuario'] })
      user_teacher = User.find_by(email: data['docente']['email'])

      teacher_data = { name: data['docente']['nome'],
                       formation: data['docente']['formacao'],
                       registration: data['docente']['usuario'],
                       occupation: data['docente']['ocupacao'],
                       email: data['docente']['email'],
                       department_id: Department.find_by(name: data['docente']['departamento']).id }
      if user_teacher
        db_teacher.update(teacher_data)
      elsif db_teacher
        UsersMailer.register_user(data['docente']['email']).deliver
      else
        db_teacher = Teacher.create(teacher_data)
        UsersMailer.register_user(data['docente']['email']).deliver
      end
      db_subject_class.update({
                                teacher_id: db_teacher.id
                              })

      new_enrollments = []
      data['discente'].each do |student|
        db_student = Student.find_by({ registration: student['matricula'] })
        user_student = User.find_by(email: student['email'])

        student_data = { name: student['nome'],
                         course: student['curso'],
                         registration: student['matricula'],
                         formation: student['formacao'],
                         occupation: student['ocupacao'],
                         email: student['email'] }

        if user_student
          db_student.update(student_data)
        elsif db_student
          UsersMailer.register_user(student['email']).deliver
        else
          db_student = Student.create(student_data)
          UsersMailer.register_user(student['email']).deliver
        end

        db_enrollment = Enrollment.find_by({
                                             student_id: db_student.id,
                                             subject_class_id: db_subject_class.id
                                           })
        db_enrollment ||= Enrollment.create({ student_id: db_student.id,
                                              subject_class_id: db_subject_class.id })

        new_enrollments << db_enrollment
      end

      db_enrollments = Enrollment.where(subject_class_id: db_subject_class.id)

      db_enrollments.each do |enr|
        enr.update(active: false) unless new_enrollments.include?(enr)
      end
    end
  end
end
