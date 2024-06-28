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

  def edit
  end

  def update
    messages = []
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
    question, messages = Question.new.create(template, question_type, title, options, options_number)

    if question.save and messages.empty?
      redirect_to edit_template_path(template)
    else
      flash[:alert] = messages.concat question.errors.full_messages
      redirect_to new_template_template_question_path(params: template_question_params)
    end
  end

  protected

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
      @options = params[:options] || QuestionService.parse_question_body(template_question.body) || ["", "", "", "", ""]
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

  def updated_data
    {
      title: title,
      question_type: question_type,
      body: QuestionService.create_question_body,
    }
  end

  def template_question_params
    params.permit(:title, :template_id, :question_type, :options_number, options: [])
  end
end
