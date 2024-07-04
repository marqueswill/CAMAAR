# A classe QuestionService é responsável por criar um corpo da questão (body), inicializá-lo e
# realizar o parsing do corpo de uma questão, se houver.
class QuestionService
  # Método para criar o corpo de uma questão a partir do tipo da questão, título, opções e número de opções.
  def self.create_question_body(question_type, _title, options, options_number)
    body = initialize_body
    messages = []

    if question_type == 'multiple_choice'
      options_number.times.each do |index|
        input = options[index]
        option_key = index + 1

        if input.empty?
          messages << "option_#{option_key}"
        else
          body['options'][option_key] = input
        end
      end
    end

    [(body.to_json if messages.empty?), messages]
  end

  # Método para fazer parsing do corpo de uma questão.
  def self.parse_question_body(body)
    JSON.parse(body)['options'].values if body
  end

  # Método para inicializar o corpo de uma questão com opções vazias.
  def self.initialize_body
    { 'options' => { 1 => '', 2 => '', 3 => '', 4 => '', 5 => '' } }
  end
end
