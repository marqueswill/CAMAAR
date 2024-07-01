class QuestionService
  def self.create_question_body(question_type, title, options, options_number)
    body = initialize_body
    messages = []

    if question_type == "multiple_choice"
      options_number.times.each do |index|
        input = options[index]
        option_key = index + 1

        if input.empty?
          messages << "option_#{option_key}"
        else
          body["options"][option_key] = input
        end
      end
    end

    [(body.to_json if messages.empty?), messages]
  end

  def self.parse_question_body(body)
    return JSON.parse(body)["options"].values if body
  end

  def self.initialize_body
    { "options" => { 1 => "", 2 => "", 3 => "", 4 => "", 5 => "" } }
  end
end
