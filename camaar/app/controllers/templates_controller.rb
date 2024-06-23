require "json"

class TemplatesController < ApplicationController
  before_action :set_admin_data
  before_action :set_template_data, only: [:destroy, :edit, :update, :show]
  before_action :check_for_commit
  layout "admin"

  def index
  end

  def new
    redirect_to edit_template_path(template)
  end

  def create
  end

  def show
    check_for_commit
  end

  def edit
  end

  def update
    if !questions.present?
      flash[:alert] = "O template precisa conter pelo menos uma pergunta"
      return redirect_to edit_template_path(template, template: template_params)
    end

    if template.update(template_params)
      redirect_to templates_path, success: "Template atualizado com sucesso!"
    end
  end

  def destroy
    if template.destroy
      redirect_to templates_path
    end
  end

  def check_for_commit
    case params[:commit]
    when "delete"
      destroy
    end
  end

  private

  # Retrieves the template instance variables needed for the view to prevent data loss after an unsuccessful form submission.
  def set_template_data
    template
    template_name
    role
    questions
  end

  # Retrieves the template instance variable based on the provided ID.
  def template
    @template = Template.find(params[:id])
  end

  # Sets the template name instance variable based on the submitted parameters or uses the default template name if none is provided.
  def template_name
    template_params = params[:template] || {}
    @template_name = template_params[:name] || template.name
  end

  # Sets the role instance variable based on the submitted parameters or uses the default role if none is provided.
  def role
    template_params = params[:template] || {}
    @role = template_params[:role] || template.role
  end

  # Retrieves the questions associated with the template and sets them to the questions instance variable.
  def questions
    @questions = TemplateQuestion.where(template_id: template.id)
  end

  # Defines the permitted parameters for the template.
  def template_params
    params.require(:template).permit(:name, :role)
  end
end
