# A classe TemplatesController gerencia ações relacionadas ao gerenciamento de templates.
# Essa classe inclui a criação, edição, atualização, visualização e deleção de templates,
# assim como possui métodos de verificação de ações específicas de commit e definição de
# variáveis de instância a serem usadas nas views.
class TemplatesController < TemplateController
  before_action :set_admin_data
  before_action :check_for_commit
  before_action :set_template_data, only: %i[destroy edit update]

  def index; end

  def new
    template = Template.create({ coordinator_id: coordinator.id })
    redirect_to edit_template_path(template)
  end

  def edit; end

  def update
    bool, symbol, msg = update?
    if bool
      flash[symbol.to_sym] = msg
      return redirect_to edit_template_path(template, template: template_params)
    end

    return unless template.update(template_params.merge(draft: false))

    redirect_to templates_path, success: 'Template atualizado com sucesso!'
  end

  def update?
    return [true, 'alert', 'O template precisa conter pelo menos uma pergunta'] unless questions.present?
    return [true, 'alert', 'Template precisa de um nome'] if params[:template][:name].empty?

    [false, '', '']
  end

  def destroy
    begin
      template.destroy
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Não foi possível encontrar o template'
    end

    redirect_to templates_path
  end
end
