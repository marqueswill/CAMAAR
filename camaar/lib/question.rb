# Classe que representa uma instância de classe que existe na família de TemplateQuestionsController para criar questões de um template
# e retornar mensagens de erro (se houver).
class Question < TemplateQuestionsController
  def create(template, question_type, title, options, options_number)
    body, messages = QuestionService.create_question_body(question_type, title, options, options_number)

    question = TemplateQuestion.new({
                                      title:,
                                      body:,
                                      question_type:,
                                      template_id: template.id
                                    })

    [question, messages]
  end
end
