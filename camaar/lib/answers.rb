# Classe que representa uma instância de classe que existe na família de AnswersController para responder
# questões de formulários e submetê-las.
class Answers
  # Método para submeter respostas de um formulário. Recebe os parâmetros das 
  # respostas e utiliza o serviço AnswerCreatonService pra criar as respostas.
  def submit_answers(answers_params, current_user, form)
    AnswerCreationService.new(current_user, answers_params, form).create_answers
  end
end
