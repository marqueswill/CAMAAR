require 'json'
require 'rchart'
require 'csv'

# AdminsController gerencia as requisições nas páginas que o administrador/coordenador tem acesso
class AdminsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_admin_data
  before_action :load

  # Carrega os templates e as classes do departamento
  def load
    @templates = Template.where(coordinator_id: @coordinator.id, draft: false)
    @classes = SubjectClass.all
  end

  # Método que funciona como setup para o envio de templates/formulários. O método em questão configura os templates de
  # professor, aluno, as classes e verifica se houve a requisição para enviar um template/formulário.
  def setup_envio(coordinator_id)
    @student_templates = Template.where({ coordinator_id: coordinator_id, draft: false, role: 'discente' })
    @teacher_templates = Template.where({ coordinator_id: coordinator_id, draft: false, role: 'docente' })
    flash.clear
    [params[:teacher_template], params[:student_template],params[:classes_ids], params[:commit]]
  end

  # Método que recebe uma requisição para enviar um template/formulário. Caso haja sucesso ou erro, serão printadas
  # as respectivas mensagens na página do administrador. Há o uso de uma instância da classe Dispatch, responsável por executar
  # os métodos de envio
  def envio
    teacher_template_id, student_template_id, classes_ids, commit = setup_envio(@coordinator.id)
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
    symbol,msg = Import.new.import_data(params[:select_data], json,current_admin.email)
    flash[symbol.to_sym] = msg
    redirect_to '/admins/import'
  end

  # Método que gerencia as requisições para a visualização e obtenção de resultados para o administrador, que consistem
  # sumariamente nas respostas de alunos e/ou professores a um formulário previamente submetido.
  def results
    @forms = Form.where(coordinator_id: @coordinator.id)

    answers = ResultsService.fill_answers(@forms)
    form_id = params[:form_id]
    setup_results(form_id)
  end

  # Método que funciona como setup para a visualização de resultados de formulários respondidos.
  # O método em questão configura os formulários e as questões, e verifica se houve ou não respostas.
  def setup_results(form_id)
    @form = Form.find_by_id(form_id) if form_id
    @form_questions = FormQuestion.where(form_id: @form.id) if @form

    mode = params[:export]
    results?(mode)
  end

  # Método auxiliar que age de forma a verificar se houve ou não respostas para um formulário acessado na view de resultados.
  # O método em questão verifica se houve ou não respostas e, caso seja requerido, configura a exportação destas.
  def results?(mode)
    if mode.present? && answers?(@form_questions)
      flash[:warning] = 'O formulário não possui respostas'
      redirect_to '/admins/results'
    else
      export?(mode)
    end
  end

  # Método auxiliar que verifica se houve questões respondidas por professores ou alunos, retornando um booleano
  def answers?(form_questions)
    form_pluck = form_questions.pluck(:id)
    students_answers = StudentAnswer.where(form_question_id: form_pluck) if form_questions
    teacher_answers = TeacherAnswer.where(form_question_id: form_pluck) if form_questions
    !(students_answers.present? or teacher_answers.present?)
  end

  # Método que gerencia as requisições para exportar os resultados de algum formulário.
  # Caso a requisição seja para 'csv', será gerado um arquivo CSV contendo as respostas do formulário.
  # Caso a requisição seja para 'graph', será gerado um arquivo png contendo um gráfico relacionado às estatísticas do form.
  def export?(mode)
    export = Export.new
    case mode
    when 'csv'
      csv_data = export.export_to_csv(@form,@form_questions)
      send_file export.fill_csv(@form.id,@form.name, csv_data), filename: "#{@form.id}_#{@form.name}.csv".gsub(' ', '_').downcase, type: 'text/csv'
    when 'graph'
      @form,@form_questions = [Form.find_by_id(params[:form_id]),FormQuestion.where(form_id: @form.id)]
      export_to_png(export)
    end
  end

  # Método que funciona como um "setup" dos parâmetros relacionados ao resumo das respostas de um formulário, configurando
  # os atributos necessários para a interação MVC.
  def summary
    @form = Form.find_by_id(params[:id])
    @form_questions = FormQuestion.where(form_id: @form.id)
    @form_answers = StudentAnswer.where(form_question_id: @form_questions[0].id)
    @total_number = @form.role == 'discente' ? Enrollment.where(subject_class_id: @form.subject_class_id).length : 1
    @answered_number,@form_summary = [@form_answers.length,generate_summary]
  end

  # Método que gerencia as requisições para efetuar um resumo das respostas de todos os usuários acerca de um
  # formulário.
  def generate_summary
    resumo = {}
    SummaryService.call(resumo, @form_questions, @form)
  end

  # Método que gerencia as requisições para exportar um gráfico de setores relacionado a algum formulário respondido.
  # O método em questão irá enviar um arquivo png do gráfico ao browser do administrador.
  def export_to_png(export)
    name,id,graph,filename = [@form.name,@form.id,export.generate_graph(@form),"#{name}.png"]
    file_path = ExportPngService.call(filename, graph)
    send_file file_path, filename: "#{id}_#{name}.png".gsub(' ', '_').downcase, type: 'image/png'
  end

end
