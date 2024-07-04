# Essa classe gerencia operações CRUD (Create, Read, Update, Delete) para a model TemplateQuestions.
# É usada no contexto de páginas do administrador para gerenciar questões associadas com templates.
# Provê métodos para listar, mostrar, editar, criar e deletar TemplateQuestions.
# A classe também possui suporte a validações para opções de questões baseadas em seus respectivos tipos.
class QuestionsController < ApplicationController

  layout "admin"

  protected

  # Método que popula variáveis de instância usadas nas views.
  def set_template_question_data
    template
    template_question
    question_type
    title
    options_number
    options
  end

  # Método auxiliar que define o template presente nos parâmetros a partir do ID.
  def template
    @template = Template.find_by_id(params[:template_id])
  end

  # Método auxiliar que define a pergunta do template presente nos parâmetros a partir 
  # do ID da questão, ou cria uma nova instância de TemplateQuestion.
  def template_question
    @template_question = TemplateQuestion.find_by_id(params[:id]) || TemplateQuestion.new
  end

  # Método auxiliar que define o tipo da questão a partir dos parâmetros, do tipo da 
  # questão ou uma string vazia.
  def question_type
    @question_type = params[:question_type] || template_question.question_type || ""
  end

  # Método auxiliar que define o título da questão a partir dos parâmetros, do atributo 
  # title de template_question ou uma string vazia.
  def title
    @title = params[:title] || template_question.title || ""
  end

  # Método auxiliar que define as opções baseado no tipo de questão e nos parâmetros ou corpo de template_question.
  def options
    if question_type == "text"
      @options = ["", "", "", "", ""]
    else
      @options = params[:options] || QuestionService.parse_question_body(template_question.body) || ["", "", "", "", ""]
    end
  end

  # Método auxiliar que define o número de opções a partir do tipo de questão, dos parâmetros 
  # ou do número de opções preenchidas.
  def options_number
    if question_type == "text"
      @options_number = 0
    else
      input = params[:options_number]
      @options_number = input ? input.to_i : 5 - options.count { |str| str.empty? }
    end
  end

  # Método auxiliar que verifica o valor do parâmetro commit e realiza redirecionamentos ou destruição.
  def check_for_commit
    case params[:commit]
    when "cancel"
      redirect_to edit_template_path(template)
    when "delete"
      destroy
    end
  end

  # Método que atualiza os dados de uma questão de um template.
  def updated_data
    {
      title: title,
      question_type: question_type,
      body: Question.new.create(template, question_type, title, options, options_number),
    }
  end

  # Método que estabelece os parâmetros para TemplateQuestions.
  def template_question_params
    params.permit(:title, :template_id, :question_type, :options_number, options: [])
  end
end
