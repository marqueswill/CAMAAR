# Essa classe gerencia operações CRUD (Create, Read, Update, Delete) para a model TemplateQuestions.
# É usada no contexto de páginas do administrador para gerenciar questões associadas com templates.
# Provê métodos para listar, mostrar, editar, criar e deletar TemplareQuestions.
# A classe também possui suporte a validações para opções de questões baseadas em seus respectivos tipos.

class TemplateQuestionsController < ApplicationController
  before_action :set_admin_data
  before_action :check_for_commit
  before_action :set_template_question_data
  before_action :set_errors

  layout "admin"

  def index
  end

  def show
  end

  def edit
    flash[:alert] = @errors[:warning] if not flash[:alert]
  end

  def update
    new_data = {
      id: params[:id].to_i,
      title: title,
      question_type: question_type,
      body: create_question_body,
      template_id: template.id,
    }

    warnings = @errors[:warning]
    if template_question.update(new_data) and warnings.empty?
      redirect_to edit_template_path(template)
    else
      warnings.concat template_question.errors.full_messages
      flash[:alert] = warnings

      redirect_to edit_template_template_question_path(template, template_question, params: template_question_params)
    end
  end

  def destroy
    if template_question.destroy
      redirect_to edit_template_path(template)
    end
  end

  def new
    flash[:alert] = @errors[:warning] if not flash[:alert]
  end

  def create
    question = TemplateQuestion.new({
      title: title,
      body: create_question_body,
      question_type: question_type,
      template_id: template.id,
    })

    warnings = @errors[:warning]
    if question.save and warnings.empty?
      redirect_to edit_template_path(template)
    else
      flash[:alert] = warnings.concat question.errors.full_messages
      redirect_to new_template_template_question_path(params: template_question_params)
    end
  end

  private

  def create_question_body
    body = initialize_body
    warnings = @errors[:warning]

    populate_options(body, warnings) if question_type == "multiple_choice"

    body.to_json if warnings.empty?
  end

  def parse_question_body
    body = template_question.body
    return JSON.parse(body)["options"].values if body
  end

  def initialize_body
    { "options" => { 1 => "", 2 => "", 3 => "", 4 => "", 5 => "" } }
  end

  def populate_options(body, warnings)
    options_number.times.each do |index|
      input = options[index]
      option_key = index + 1

      if input.empty?
        warnings << "option_#{option_key}"
        # warnings << "option_#{option_key} Campo não pode estar vazio"
      else
        body["options"][option_key] = input
      end
    end
  end

  def set_template_question_data
    template
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

  def check_for_commit
    case params[:commit]
    when "cancel"
      redirect_to edit_template_path(template)
    when "delete"
      destroy
    end
  end

  def template_question_params
    params.permit(:title, :question_type, :options_number, options: [])
  end
end
