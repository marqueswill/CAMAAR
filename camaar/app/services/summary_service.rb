# Classe que representa um serviço da AdminsController de gerar um resumo das respostas de um formulário.
# Efetua as operações de resumo e de estatísticas referentes a respostas de formulários de
# alunos e professores.
class SummaryService
  # Método para gerar summary das respostas de um formulário.
  def self.call(form_questions, form)
    resumo = {}
    form_questions.each do |question|
      form_question_id = question.id

      answers = if form.role == 'discente'
                  StudentAnswer.where(form_question_id:)
                else
                  TeacherAnswer.where(form_question_id:)
                end

      question_body = JSON.parse(question.body)
      answers.each do |answ|
        answer_body = JSON.parse(answ.answers)['answers']

        case question.question_type
        when 'text'
          resumo[question.title] ||= []
          resumo[question.title] << answer_body
        when 'multiple_choice'
          resumo[question.title] ||= {}
          options = question_body['options']
          options.each do |option|
            option_question = option[1]
            resumo[question.title][option_question] ||= 0 if option_question != ''
          end

          answer_body.each do |item, selected|
            resumo[question.title][options[item]] += 1 if selected
          end
        end
      end
    end

    resumo
  end
end
