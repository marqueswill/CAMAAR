class Results < AdminsController
   # Método auxiliar que verifica se houve questões respondidas por professores ou alunos, retornando um booleano
   def answers?(form_questions)
    form_pluck = form_questions.pluck(:id)
    students_answers = StudentAnswer.where(form_question_id: form_pluck) if form_questions
    teacher_answers = TeacherAnswer.where(form_question_id: form_pluck) if form_questions
    !(students_answers.present? or teacher_answers.present?)
  end
end
