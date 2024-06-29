class DocenteService
    def initialize(user)
      @user = user
    end

    def forms
      teacher = Teacher.find_by(email: @user.email)
      subject_classes = SubjectClass.where(teacher_id: teacher.id)
      if subject_classes.empty?
        []
      else
        Form.where(subject_class_id: subject_classes.pluck(:id), role: 'docente')
      end
    end

    def get_answers(form_questions)
      teacher = Teacher.find_by(email: @user.email)
      TeacherAnswer.where(form_question_id: form_questions.pluck(:id), teacher_id: teacher.id)
    end

    def find_answer(question)
      teacher = Teacher.find_by(email: @user.email)
      TeacherAnswer.find_by(form_question_id: question.id, teacher_id: teacher.id)
    end
end
