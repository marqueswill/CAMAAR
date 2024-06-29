# app/services/answer_creation_service.rb
class AnswerCreationService
    def initialize(current_user, answers_params, form)
      @current_user = current_user
      @answers_params = answers_params
      @form = form
    end
  
    def create_answers
      @answers_params.each do |question_id, answer|
        form_question = FormQuestion.find(question_id.to_i)
        next unless form_question
  
        handle_occupation(answer, form_question, question_id)
      end
    end
  
    private
  
    def create_answer_body(answer, form_question)
      question_body = JSON.parse(form_question.body)
      answer_body = { "answers" => {} }
  
      if form_question.question_type == "multiple_choice"
        question_body["options"].each do |option_number, value|
          answer_body["answers"][option_number.to_s] = (option_number == answer)
        end
      else
        answer_body["answers"] = answer
      end
  
      answer_body.to_json
    end
  
    def handle_occupation(answer, form_question, question_id)
      case @current_user.occupation
      when "discente"
        StudentAnswer.create(
          answers: create_answer_body(answer, form_question),
          form_question_id: question_id,
          student_id: @current_user.id
        )
      when "docente"
        TeacherAnswer.create(
          answers: create_answer_body(answer, form_question),
          form_question_id: question_id,
          teacher_id: @current_user.id
        )
      end
    end
    
  end
  