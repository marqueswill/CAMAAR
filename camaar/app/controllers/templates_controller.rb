# A classe TemplatesController gerencia ações relacionadas ao gerenciamento de templates.
# Essa classe inclui a criação, edição, atualização, visualização e deleção de templates,
# assim como possui métodos de verificação de ações específicas de commit e definição de
# variáveis de instância a serem usadas nas views.
class TemplatesController < TemplateController
  before_action :set_admin_data
  before_action :check_for_commit
  before_action :set_template_data, only: %i[destroy edit update]

  # Método para exibir a lista de templates.
  def index; end

  # Método para criar um novo template e redirecionar pra página de edição desse template.
  def new
    template = Template.create({ coordinator_id: coordinator.id })
    redirect_to edit_template_path(template)
  end

  # Método para exibir página de edição de um template.
  def edit; end

  # Método para atualizar um template.
  def update
    bool, symbol, msg = update?
    if bool
      flash[symbol.to_sym] = msg
      return redirect_to edit_template_path(template, template: template_params)
    end

    return unless template.update(template_params.merge(draft: false))

    redirect_to templates_path, success: 'Template atualizado com sucesso!'
  end

  # Método auxiliar que verifica as condições necessárias antes de atualizar um template.
  def update?
    return [true, 'alert', 'O template precisa conter pelo menos uma pergunta'] unless questions.present?
    return [true, 'alert', 'Template precisa de um nome'] if params[:template][:name].empty?

    [false, '', '']
  end

  # Método que deleta um template e redireciona.
  def destroy
    begin
      template.destroy
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Não foi possível encontrar o template'
    end

    redirect_to templates_path
  end
end
