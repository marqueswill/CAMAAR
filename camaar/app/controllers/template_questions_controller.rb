# Essa classe gerencia operações CRUD (Create, Read, Update, Delete) para a model TemplateQuestions.
# É usada no contexto de páginas do administrador para gerenciar questões associadas com templates.
# Provê métodos para listar, mostrar, editar, criar e deletar TemplareQuestions.
# A classe também possui suporte a validações para opções de questões baseadas em seus respectivos tipos.

class TemplateQuestionsController < ApplicationController
  before_action :set_admin_data
  before_action :check_for_commit
  before_action :set_template_data, :set_template_question_data
  before_action :set_errors

  layout "admin"

  def edit
  end

  def update
    messages = warnings
    question = template_question
    if question.update(updated_data) and messages.empty?
      redirect_to edit_template_path(template)
    else
      flash[:alert] = messages.concat question.errors.full_messages
      redirect_to edit_template_template_question_path(template, template_question, params: template_question_params)
    end
  end

  def destroy
    if template_question.destroy
      redirect_to edit_template_path(template)
    end
  end

  def new
  end

  def create
    question = TemplateQuestion.new({
      title: title,
      body: create_question_body,
      question_type: question_type,
      template_id: template.id,
    })

    messages = warnings
    if question.save and messages.empty?
      redirect_to edit_template_path(template)
    else
      flash[:alert] = messages.concat question.errors.full_messages
      redirect_to new_template_template_question_path(params: template_question_params)
    end
  end

  private

  def create_question_body
    body = initialize_body
    messages = warnings

    populate_options(body, messages) if question_type == "multiple_choice"

    body.to_json if messages.empty?
  end

  def parse_question_body
    body = template_question.body
    return JSON.parse(body)["options"].values if body
  end

  def initialize_body
    { "options" => { 1 => "", 2 => "", 3 => "", 4 => "", 5 => "" } }
  end

  def populate_options(body, messages)
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

  def set_template_data
    template
  end

  def set_template_question_data
    template_question
    question_type
    title
    options_number
    options
  end

  def template
    @template = Template.find_by_id(params[:template_id])
  end

  def template_question
    @template_question = TemplateQuestion.find_by_id(params[:id]) || TemplateQuestion.new
  end

  def question_type
    @question_type = params[:question_type] || template_question.question_type || ""
  end

  def title
    @title = params[:title] || template_question.title || ""
  end

  def options
    if question_type == "text"
      @options = ["", "", "", "", ""]
    else
      @options = params[:options] || parse_question_body || ["", "", "", "", ""]
    end
  end

  def options_number
    if question_type == "text"
      @options_number = 0
    else
      input = params[:options_number]
      @options_number = input ? input.to_i : 5 - options.count { |str| str.empty? }
    end
  end

  def warnings
    set_errors[:warning]
  end

  def check_for_commit
    case params[:commit]
    when "cancel"
      redirect_to edit_template_path(template)
    when "delete"
      destroy
    end
  end

  def updated_data
    {
      title: title,
      question_type: question_type,
      body: create_question_body,
    }
  end

  def template_question_params
    params.permit(:title, :question_type, :options_number, options: [])
  end
end
