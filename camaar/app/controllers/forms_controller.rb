# A classe FormsController gerencia as funcionalidas referentes aos formulários.
# Essa classe contém os métodos públicos responsáveis por mostrar e editar os formulários.
# Também contém métodos privados que são responsáveis por realizar as partes mais lógicas do
# código, como identificar o tipo de usuário, identificar as questões e as respostas de um formulário.
class FormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_data
  before_action :initialize_data
  layout "user"

  # Método para exibir a lista de formulários
  def index
    render :index, locals: { forms: filtered_forms }
  end

  # Método para editar um formulário específico
  def edit
    form = find_form
    render :edit, locals: { form: form, form_questions: form.form_question }
  end

  # Método para atualizar um formulário (ainda não implementado)
  def update; end

  # Método para exibir um formulário específico
  def show
    form = find_form
    form_questions = form.form_question
    render :show, locals: { 
      form: form, 
      form_questions: form_questions,
      questions_and_answers: set_questions_and_answers(form_questions)
    }
  end

  private

  # Atributos para evitar variáveis de instância
  attr_reader :user_service, :filter

  # Inicializa os dados do usuário atual
  def initialize_data
    @user_service = user_service_for_current_user
    @filter = params[:filter] || "pending"
  end

  # Retorna o tipo de usuário ("teacher" ou "student") para o método initalize_data realizar a
  # inicialização corretamente
  def user_service_for_current_user
    if current_user.discente?
      DiscenteService.new(current_user)
    elsif current_user.docente?
      DocenteService.new(current_user)
    else
      raise "Tipo de usuário não suportado"
    end
  end

  # Filtra os formulários entre "pendentes" e "respondidos" para a redenrização correta na view correspondente
  def filtered_forms
    forms = user_service.forms
    return [] if forms.empty?

    categorized_forms = categorize_forms(forms)
    filter == "pending" ? categorized_forms[:pending] : categorized_forms[:answered]
  end

  # Categoriza os formulários em pendentes e respondidos para o método filtered_forms
  def categorize_forms(forms)
    FormCategorizerService.categorize(forms, user_service)
  end
  
  # Define as questões e respostas para um formulário específico
  def set_questions_and_answers(form_questions)
    form_questions.map do |question|
      answer = user_service.find_answer(question)
      [question, answer]
    end
  end

  # Encontra um formulário pelo ID
  def find_form
    Form.find(params[:id])
  end
end