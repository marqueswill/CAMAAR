require "json"

# A classe TemplatesController gerencia ações relacionadas ao gerenciamento de templates.
# Essa classe inclui a criação, edição, atualização, visualização e deleção de templates,
# assim como possui métodos de verificação de ações específicas de commit e definição de
# variáveis de instância a serem usadas nas views.

class TemplatesController < ApplicationController
  before_action :set_admin_data
  before_action :check_for_commit
  before_action :set_template_data, only: [:destroy, :edit, :update, :show]
  layout "admin"


  def index
  end

  def new
    template = Template.create({ coordinator_id: coordinator.id })
    redirect_to edit_template_path(template)
  end

  def create
  end

  def show

  end

  def edit
  end

  def update
    if !questions.present?
      flash[:alert] = "O template precisa conter pelo menos uma pergunta"
      return redirect_to edit_template_path(template, template: template_params)
    end

    if template.update(template_params.merge(draft: false))
      redirect_to templates_path, success: "Template atualizado com sucesso!"
    end
  end

  def destroy
    begin
      template.destroy
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Não foi possível encontrar o template"
    end

    redirect_to templates_path
  end

  def check_for_commit
    case params[:commit]
    when "delete"
      destroy
    end
  end

  private

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
