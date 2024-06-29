class Question < TemplateQuestionsController
  def create(template,question_type, title, options, options_number)
    body, messages = QuestionService.create_question_body(question_type, title, options, options_number)

    puts body, messages

    question = TemplateQuestion.new({
      title: title,
      body: body,
      question_type: question_type,
      template_id: template.id,
    })

    [question, messages]
  end
end
