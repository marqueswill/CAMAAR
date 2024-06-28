class ResultsService
  def self.call(form); end

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
