require 'json'
require 'rchart'
require 'csv'
# A classe AdminsController gerencia as principais ações relacionadas às funcionalidades do administrador.
# Essa classe inclui a importação de dados, a exportação de resultados em CSV e Gráficos, visualização de
# respostas de formulários, gerenciamento de templates etc.
class AdminsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_admin_data
  before_action :load
  attr_reader :coordinator, :classes, :forms

  # Carrega os templates e as classes do departamento
  def load
    coord_id = coordinator.id
    @templates = Template.where(coordinator_id: coord_id, draft: false)
    @forms = Form.where(coordinator_id: coord_id)
  end

  # Método que funciona como setup para o envio de templates/formulários. O método em questão configura os templates de
  # professor, aluno, as classes e verifica se houve a requisição para enviar um template/formulário.
  def setup_envio(coordinator_id)
    @student_templates = Template.where({ coordinator_id:, draft: false, role: 'discente' })
    @teacher_templates = Template.where({ coordinator_id:, draft: false, role: 'docente' })
    flash.clear
    [params[:teacher_template], params[:student_template], params[:classes_ids], params[:commit]]
  end

  # Método que recebe uma requisição para enviar um template/formulário. Caso haja sucesso ou erro, serão printadas
  # as respectivas mensagens na página do administrador. Há o uso de uma instância da classe Dispatch, responsável por executar
  # os métodos de envio
  def envio
    teacher_template_id, student_template_id, classes_ids, commit = setup_envio(coordinator.id)
    dispatch = Dispatch.new
    case dispatch.commit?(classes_ids, commit)
    when true
      dispatch.execute(classes_ids, student_template_id, teacher_template_id).each do |item|
        flash[item[0].to_sym] = item[1]
      end
    when false
      flash[:warning] = 'Selecione as turmas para envio.'
    end
  end

  # Método que recebe uma requisição para importar algum dado a partir de um json. Caso haja sucesso ou erro, serão printadas
  # as respectivas mensagens na página do administrador. Há o uso de uma instância da classe Import, responsável por executar
  # os métodos de importação.
  def import
    @errors = []
    json = JSON.parse(File.read(params[:admin_import][:file].tempfile.path))
    symbol, msg = Import.new.import_data(params[:select_data], json, current_admin.email)
    flash[symbol.to_sym] = msg
    redirect_to '/admins/import'
  end

  # Método que gerencia as requisições para a visualização e obtenção de resultados para o administrador, que consistem
  # sumariamente nas respostas de alunos e/ou professores a um formulário previamente submetido.
  def results
    ResultsService.fill_answers(forms)
    form_id = params[:form_id]

    setup_results(form_id) if form_id
  end

  # Método que funciona como setup para a visualização de resultados de formulários respondidos.
  # O método em questão configura os formulários e as questões, e verifica se houve ou não respostas.
  def setup_results(form_id)
    form = Form.find_by_id(form_id)
    form_questions = FormQuestion.where(form_id:)

    mode = params[:export]
    results?(mode, form, form_questions)
  end

  # Método auxiliar que age de forma a verificar se houve ou não respostas para um formulário acessado na view de resultados.
  # O método em questão verifica se houve ou não respostas e, caso seja requerido, configura a exportação destas.
  def results?(mode, form, form_questions)
    if mode.present? && Results.new.answers?(form_questions)
      flash[:warning] = 'O formulário não possui respostas'
      redirect_to '/admins/results'
    else
      file, filename, type = Export.new.execute(mode, form, form_questions)
      send_file file, filename:, type:
    end
  end

  # Método que funciona como um "setup" dos parâmetros relacionados ao resumo das respostas de um formulário, configurando
  # os atributos necessários para a interação MVC.
  def summary
    form
    form_questions
    summary?
  end

  # Método que executa métodos essenciais para receber o número de respostas do formulário e o número de questões,
  # além de possuir uma instância de objeto da classe Results que é responsável por gerar um resumo das questões
  # respondidas do formulário em questão
  def summary?
    total_number
    answered_number
    @form_summary = Results.new.generate_summary(form_questions, form)
  end

  # Método que recupera o respectivo formulário acessado
  def form
    @form = Form.find_by_id(params[:id])
  end

  # Método que recupera as questões do respectivo formulário acessado
  def form_questions
    @form_questions = FormQuestion.where(form_id: form.id)
  end

  # Método que recupera o total quantitativo dos alunos/professores que podem responder o respectivo formulário acessado
  def total_number
    @total_number = form.role == 'discente' ? Enrollment.where(subject_class_id: form.subject_class_id).length : 1
  end

  # Método que recupera o total quantitativo dos alunos/professores que responderam o respectivo formulário acessado
  def answered_number
    @answered_number = StudentAnswer.where(form_question_id: form_questions[0].id).length
  end
end
