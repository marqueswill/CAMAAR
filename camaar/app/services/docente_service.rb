class DocenteService
    def initialize(user)
      @user = user
    end

    def forms
      teacher = Teacher.find_by(user_id: @user.id)
      subject_classes = SubjectClass.find_by(teacher_id: teacher.id)
      if subject_classes.empty?
        []
      else
        Form.where(subject_class_id: subject_classes.pluck(:id), role: 'docente')
      end
    end

    def get_answers(form_questions)
      teacher = Teacher.find_by(user_id: @user.id)
      TeacherAnswer.where(form_question_id: form_questions.pluck(:id), teacher_id: teacher.id)
    end

    def find_answer(question)
      teacher = Teacher.find_by(user_id: @user.id)
      TeacherAnswer.find_by(form_question_id: question.id, teacher_id: teacher.id)
    end
end
