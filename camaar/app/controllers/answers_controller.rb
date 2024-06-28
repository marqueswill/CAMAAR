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
    answers_params = params[:answers]

    if answers_params.present?
      answers_params.each do |id, answ|
        if answ.empty?
          flash[:error] = "Responda todas questões."
          redirect_to edit_form_path(@form) and return
        end
      end
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