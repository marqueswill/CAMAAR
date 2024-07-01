class Answers < AnswersController
  def submit_answers(answers_params, commit, current_user, form)
    if commit == "Enviar"
      AnswerCreationService.new(current_user, answers_params, form).create_answers
      ['/users/forms','']
    else
      ["/users/forms/#{form.id}/edit",'warning']
    end
  end
end
