class SummaryService
  def self.call(resumo, form_questions, form)
    form_questions.each do |question|
      answers = if form.role == 'discente'
                  StudentAnswer.where(form_question_id: question.id)
                else
                  TeacherAnswer.where(form_question_id: question.id)
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
          question_body['options'].each do |option|
            resumo[question.title][option[1]] ||= 0 if option[1] != ''
          end

          answer_body.each do |k, selected|
            resumo[question.title][question_body['options'][k]] += 1 if selected
          end
        end
      end
    end

    resumo
  end
end
