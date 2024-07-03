# Classe que representa um serviço da AdminsController de importar membros.
# Efetua as operações de importação de classes, professores e alunos.
class ImportMembersService
  def self.call(members)
    members.each do |data|
      subject = data['code']
      code = data['classCode']
      semester = data['semester']
      db_subject_class = SubjectClass.find_by(
        { subject:,
          code:,
          semester: }
      )

      unless db_subject_class
        @errors << %(#{subject}-#{code}-#{semester} Turma não foi encontrada)
        next
      end

      register_teacher(data, db_subject_class)
      register_student(data, db_subject_class)
    end
  end

  def self.register_student(data, db_subject_class)
    new_enrollments = []
    subject_class_id = db_subject_class.id

    data['discente'].each do |student|
      name = student['nome']
      course = student['curso']
      registration = student['matricula']
      formation = student['formacao']
      occupation = student['ocupacao']
      email = student['email']

      db_student = Student.find_by({ registration: })
      user_student = User.find_by(email:)

      student_data = { name:,
                       course:,
                       registration:,
                       formation:,
                       occupation:,
                       email: }

      if user_student
        db_student.update(student_data)
      elsif !db_student
        db_student = Student.create(student_data)
      end

      UsersMailer.register_user(email).deliver

      student_id = db_student.id
      db_enrollment = Enrollment.find_by({
                                           student_id:,
                                           subject_class_id:
                                         })
      db_enrollment ||= Enrollment.create({ student_id:,
                                            subject_class_id: })

      new_enrollments << db_enrollment
    end

    db_enrollments = Enrollment.where(subject_class_id:)

    db_enrollments.each do |enr|
      enr.update(active: false) unless new_enrollments.include?(enr)
    end
  end

  def self.register_teacher(data, db_subject_class)
    data_docente = data['docente']
    name = data_docente['nome']
    formation = data_docente['formacao']
    registration = data_docente['usuario']
    occupation = data_docente['ocupacao']
    email = data_docente['email']
    department_id = Department.find_by(name: data_docente['departamento']).id

    db_teacher = Teacher.find_by({ registration: })
    user_teacher = User.find_by(email:)

    teacher_data = { name:,
                     formation:,
                     registration:,
                     occupation:,
                     email:,
                     department_id: }
    if user_teacher
      db_teacher.update(teacher_data)
    elsif !db_teacher
      db_teacher = Teacher.create(teacher_data)
    end
    UsersMailer.register_user(email).deliver

    db_subject_class.update({
                              teacher_id: db_teacher.id
                            })
  end
end
