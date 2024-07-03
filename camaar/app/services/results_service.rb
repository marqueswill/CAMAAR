# Classe que representa um serviço da AdminsController de gerar respostas de um formulário.
class ResultsService
  # Método que executa o serviço de gerar respostas de um formulário.
  def self.call(form); end

  # Método que preenche as respostas dos formulários fornecidos.
  def self.fill_answers(forms)
    answers = []
    forms.each do |form|
      @form_questions = FormQuestion.where(form_id: form.id)

      occupation = form.role
      case occupation
      when 'discente'
        answers = StudentAnswer.where(form_question_id: @form_questions.pluck(:id)) if @form_questions
      when 'docente'
        answers = TeacherAnswer.where(form_question_id: @form_questions.pluck(:id)) if @form_questions
      end
    end
    answers
  end
end
