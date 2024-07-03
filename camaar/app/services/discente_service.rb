# Serviço responsável por visualizar respostas de formulários de um aluno
class DiscenteService
  # Método para inicializar o serviço com o discente associado.
  def initialize(user)
    @user = user
  end

  # Método que retorna todos os formulários relacionados às classes que um aluno está matriculado.
  def forms
    student = Student.find_by(email: @user.email)
    return [] if student.nil?

    enrollments = Enrollment.where(student_id: student.id)
    subject_class_ids = enrollments.pluck(:subject_class_id)

    Form.where(subject_class_id: subject_class_ids, role: 'discente')
  end

  # def get_answers(form_questions)
  #   student = Student.find_by(email: @user.email)
  #   StudentAnswer.where(form_question_id: form_questions.pluck(:id), student_id: student.id)
  # end

  # Método para encontrar a resposta de um aluno a uma questão específica de um formulário.
  def find_answer(question)
    student = Student.find_by(email: @user.email)
    StudentAnswer.find_by(form_question_id: question.id, student_id: student.id)
  end
end
