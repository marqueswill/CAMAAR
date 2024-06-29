require "csv"

class AnswersController < ApplicationController
  before_action :set_user_data
  before_action :validate_answers, only: :create
  layout "user"

  def create
    @form = Form.find_by_id(params[:form_id])
    path = submit_answers(params[:answers], params[:commit], current_user, @form)
    redirect_to path
  end

  private

  def validate_answers
    @form = Form.find_by_id(params[:form_id])

    questions = FormQuestion.where(form_id: @form.id)
    answers_params = params[:answers]
    if answers_params.present?
      questions.each do |question|
        answ = answers_params[(question.id).to_s]
        if not answ or answ.empty?
          flash[:error] = "Responda todas questões."
          redirect_to edit_form_path(@form) and return
        end
      end
    end

    @errors = []

    if params[:commit] and params[:commit] == "Enviar"
      case occupation
      when "discente"
        answers_params.each do |question_id, answer|
          @form_question = FormQuestion.find(question_id.to_i)
          next unless @form_question

          StudentAnswer.create(
            answers: create_answer_body(answer),
            form_question_id: question_id,
            student_id: @student.id,
          )
        end
      when "docente"
        answers_params = params[:answers]

        answers_params.each do |question_id, answer|
          @form_question = FormQuestion.find(question_id.to_i)
          next unless @form_question

          TeacherAnswer.create(
            answers: create_answer_body(answer),
            form_question_id: question_id,
            teacher_id: current_user.id,
          )
        end
      end

      redirect_to forms_path
    else
      flash[:warning] = @errors
      redirect_to edit_form_path(id: @form.id)
      # redirect_to "/users/forms/#{}/edit/"
    end
  end

  def submit_answers(answers_params, commit, current_user, form)
    if commit == "Enviar"
      AnswerCreationService.new(current_user, answers_params, form).create_answers
      forms_path
    else
      flash[:warning] = @errors
      edit_form_path(id: form.id)
    end
  end
end