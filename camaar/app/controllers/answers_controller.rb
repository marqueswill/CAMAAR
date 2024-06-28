require "csv"

class AnswersController < ApplicationController
  before_action :set_user_data
  layout "user"

  def create
    occupation = current_user.occupation

    @form = Form.find_by_id(params[:form_id])
    answers_params = params[:answers]

    if answers_params.present?
      answers_params.each do |id, answ|
        if answ.empty?
          flash[:error] = "Responda todas questões."
          redirect_to edit_form_path(@form) and return
        end
      end
    end

    process_answers(answers_params, params[:commit], occupation)
  end

  private

  def process_answers(answers_params, commit, occupation)
    @errors = []

    if commit && commit == "Enviar"
      handle_answer_submission(occupation, answers_params)
      redirect_to forms_path
    else
      flash[:warning] = @errors
      redirect_to edit_form_path(id: @form.id)
    end
  end

  def handle_answer_submission(occupation, answers_params)
    case occupation
    when "discente"
      StudentAnswersService.new(current_user, @form, answers_params).create_answers
    when "docente"
      TeacherAnswersService.new(current_user, @form, answers_params).create_answers
    end
  end
end
