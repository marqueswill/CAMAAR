require "json"

# A classe TemplatesController gerencia ações relacionadas ao gerenciamento de templates.
# Essa classe inclui a criação, edição, atualização, visualização e deleção de templates,
# assim como possui métodos de verificação de ações específicas de commit e definição de
# variáveis de instância a serem usadas nas views.

class TemplateController < ApplicationController

  layout "admin"

  def check_for_commit
    case params[:commit]
    when "delete"
      destroy
    end
  end

  protected

  def set_template_data
    template
    template_name
    role
    questions
  end

  def template
    @template = Template.find(params[:id])
  end

  def template_name
    template_params = params[:template] || {}
    @template_name = template_params[:name] || template.name
  end

  def role
    template_params = params[:template] || {}
    @role = template_params[:role] || template.role
  end

  def questions
    @questions = TemplateQuestion.where(template_id: template.id)
  end

  def template_params
    params.require(:template).permit(:name, :role)
  end

end
