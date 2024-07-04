require 'json'

# A classe TemplatesController gerencia ações relacionadas ao gerenciamento de templates.
# Essa classe inclui a criação, edição, atualização, visualização e deleção de templates,
# assim como possui métodos de verificação de ações específicas de commit e definição de
# variáveis de instância a serem usadas nas views.
class TemplateController < ApplicationController
  layout 'admin'

  # Método para verificar ações de commit.
  def check_for_commit
    case params[:commit]
    when 'delete'
      destroy
    end
  end

  protected

  # Método auxiliar que popula variáveis de instância usadas na view.
  def set_template_data
    template
    template_name
    role
    questions
  end

  # Método auxiliar que define o template a partir do ID nos parâmetros.
  def template
    @template = Template.find(params[:id])
  end

  # Método auxiliar que define o nome do template a partir de name nos parâmetros
  # ou do atributo name de template.
  def template_name
    template_params = params[:template] || {}
    @template_name = template_params[:name] || template.name
  end

  # Método auxiliar que define o papel a partir de role nos parâmetros ou do atributo
  # role de template.
  def role
    template_params = params[:template] || {}
    @role = template_params[:role] || template.role
  end

  # Método auxiliar que define as perguntas a partir do ID do template.
  def questions
    @questions = TemplateQuestion.where(template_id: template.id)
  end

  # Método auxiliar que permite somente os parâmetros name e role pro template.
  def template_params
    params.require(:template).permit(:name, :role)
  end
end
