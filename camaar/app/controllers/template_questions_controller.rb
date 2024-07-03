# Essa classe gerencia operações CRUD (Create, Read, Update, Delete) para a model TemplateQuestions.
# É usada no contexto de páginas do administrador para gerenciar questões associadas com templates.
# Provê métodos para listar, mostrar, editar, criar e deletar TemplareQuestions.
# A classe também possui suporte a validações para opções de questões baseadas em seus respectivos tipos.
class TemplateQuestionsController < QuestionsController
  before_action :set_admin_data
  before_action :check_for_commit
  before_action :set_template_question_data

  # Método para exibir a página de edição de uma pergunta do template.
  def edit; end

  # Método para remover uma pergunta do template.
  def destroy
    return unless template_question.destroy

    redirect_to edit_template_path(template)
  end

  # Método para exibir a página de criação de uma nova pergunta.
  def new; end
  
  # Método para criar nova pergunta do template.
  def create
    question, messages = Question.new.create(template, question_type, title, options, options_number)

    if question.save and messages.empty?
      redirect_to edit_template_path(template)
    else
      flash[:alert] = messages.concat question.errors.full_messages
      redirect_to new_template_template_question_path(params: template_question_params)
    end
  end

  # Método para atualizar uma pergunta de um template existente.
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
end
