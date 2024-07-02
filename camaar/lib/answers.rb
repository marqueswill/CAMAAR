# Classe que representa uma instância de classe que existe na família de AnswersController para responder
# questões de formulários e submetê-las.
class Answers < AnswersController
  def submit_answers(answers_params, current_user, form)
    AnswerCreationService.new(current_user, answers_params, form).create_answers
    ['/users/forms']
  end
end
