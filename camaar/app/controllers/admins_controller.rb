require 'json'
require 'rchart'
require 'csv'

class AdminsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_admin_data
  before_action :load

  def load
    @templates = Template.where(coordinator_id: @coordinator.id, draft: false)
    @classes = SubjectClass.all
  end

  def setup_envio
    @student_templates = Template.where({ coordinator_id: @coordinator.id, draft: false, role: 'discente' })
    @teacher_templates = Template.where({ coordinator_id: @coordinator.id, draft: false, role: 'docente' })
    flash.clear
    [params[:teacher_template], params[:student_template],params[:classes_ids], params[:commit]]
  end

  def envio
    teacher_template_id, student_template_id, classes_ids, commit = setup_envio
    case commit?(classes_ids, commit)
    when true
      classes_ids.each do |subject_class_id|
        dispatch?(teacher_template_id,student_template_id,subject_class_id)
      end
    when false
      flash[:warning] = 'Selecione as turmas para envio.'
    end
  end

  def dispatch?(teacher_template_id,student_template_id,subject_class_id)
    if !teacher_template_id.present? && !student_template_id.present?
      flash[:warning] = 'Selecione pelo menos um template para envio.'
    else
      dispatch_teacher_template(teacher_template_id, subject_class_id) if teacher_template_id.present?
      dispatch_student_template(student_template_id, subject_class_id) if student_template_id.present?
    end
  end

  def commit?(classes_ids,commit)
    if classes_ids.present? && commit == 'confirm'
      return true
    else
      return false
    end
  end

  def dispatch_teacher_template(teacher_template_id,subject_class_id)
    teacher_form, teacher_template = setup_teacher_form(teacher_template_id,subject_class_id)
    return unless teacher_form.save
    DispatchTemplateService.dispatch_teacher(teacher_template,teacher_form)
    flash[:success] = "O formulário para o professor da turma #{SubjectClass.find_by(id: subject_class_id).name} foi criado com sucesso.<br>"
  end

  def dispatch_student_template(student_template_id, subject_class_id)
    student_form, student_template = setup_student_form(student_template_id, subject_class_id)
    return unless student_form.save
    DispatchTemplateService.dispatch_student(student_template,student_form)
    flash[:success] = "O formulário para os alunos da turma #{SubjectClass.find_by(id: subject_class_id).name} foi criado com sucesso.<br>"
  end

  def setup_student_form(student_template_id, subject_class_id)
    student_template = Template.find_by(id: student_template_id)
    student_form = Form.new(
      name: student_template.name,
      coordinator_id: student_template.coordinator_id,
      subject_class_id:
    )
    [student_form, student_template]
  end

  def setup_teacher_form(teacher_template_id, subject_class_id)
    teacher_template = Template.find_by(id: teacher_template_id, draft: false)
    teacher_form = Form.new(
      role: teacher_template.role,
      name: teacher_template.name,
      coordinator_id: teacher_template.coordinator_id,
      subject_class_id:
    )
    [teacher_form,teacher_template]
  end

  def import
    @errors = []
    json = params[:admin_import][:file].tempfile.path
    selected_data = params[:select_data]
    import_data(selected_data, json)
  end

  def import_data(selected_data, json)
    file = JSON.parse(File.read(json))
    case selected_data
    when '1'
      import_members(file)
    when '2'
      import_classes(file)
    when '3'
      import_departments(file)
    end
    redirect_to '/admins/import'
  end

  def import_departments(file)
    if root?
      ImportDepartmentsService.call(file)
    else
      flash[:error] = 'Você não é admin ROOT'
    end
  end

  def import_classes(file)
    ImportClassesService.call(file)
    flash[:notice] = 'Turmas importadas com sucesso'
  end

  def import_members(file)
    ImportMembersService.call(file)
    flash[:notice] = 'Membros importados com sucesso'
  end

  def root?
    root_dpto = Department.find_by(initials: 'ROOT')
    return false if root_dpto.nil?

    root_cord = Coordinator.find_by(department_id: root_dpto.id)
    current_admin&.email == root_cord&.email
  end

  def results
    @forms = Form.where(coordinator_id: @coordinator.id)

    answers = ResultsService.fill_answers(@forms)
    form_id = params[:form_id]
    setup_results(form_id)
  end

  def setup_results(form_id)
    @form = Form.find_by_id(form_id) if form_id
    @form_questions = FormQuestion.where(form_id: @form.id) if @form

    mode = params[:export]
    results?(mode)
  end

  def results?(mode)
    if mode.present? && answers?(@form_questions)
      flash[:warning] = 'O formulário não possui respostas'
      redirect_to '/admins/results'
    else
      export?(mode)
    end
  end

  def answers?(form_questions)
    form_pluck = form_questions.pluck(:id)
    students_answers = StudentAnswer.where(form_question_id: form_pluck) if form_questions
    teacher_answers = TeacherAnswer.where(form_question_id: form_pluck) if form_questions
    !(students_answers.present? or teacher_answers.present?)
  end

  def export?(mode)
    case mode
    when 'csv'
      export_to_csv
    when 'graph'
      @form = Form.find_by_id(params[:form_id])
      @form_questions = FormQuestion.where(form_id: @form.id)
      export_to_png
    end
  end

  def summary
    @form = Form.find_by_id(params[:id])
    @form_questions = FormQuestion.where(form_id: @form.id)
    @form_answers = StudentAnswer.where(form_question_id: @form_questions[0].id)
    # @form_status = @form.open ? "Aberto": "Fechado"

    @total_number = if @form.role == 'discente'
                      Enrollment.where(subject_class_id: @form.subject_class_id).length
                    else
                      1
                    end
    @answered_number = @form_answers.length

    @form_summary = generate_summary
  end

  def generate_summary
    resumo = {}
    SummaryService.call(resumo, @form_questions, @form)
  end

  def export_to_csv
    csv_string = generate_csv
    csv_data = CSV.parse(csv_string, headers: true)
    file_path = fill_csv(@form, csv_data)
    send_file file_path, filename: "#{@form.id}_#{@form.name}.csv".gsub(' ', '_').downcase, type: 'text/csv'
  end

  def fill_csv(form, csv_data)
    file_path = Rails.root.join('export', "#{form.id}_#{form.name}_results.csv")
    directory_path = File.dirname(file_path)
    FileUtils.mkdir_p(directory_path) unless File.directory?(directory_path)

    CSV.open(file_path, 'w') do |csv|
      csv << csv_data.headers

      csv_data.each do |row|
        csv << row
      end
    end
    file_path
  end

  def export_to_png
    graph = generate_graph
    filename = "#{@form.name}.png"
    file_path = ExportPngService.call(filename, graph)
    send_file file_path, filename: "#{@form.id}_#{@form.name}.png".gsub(' ', '_').downcase, type: 'image/png'
  end

  def generate_graph
    case @form.role
    when 'discente'
      ch = ExportPngService.generate_teacher_graph(@form)
    when 'docente'
      ch = ExportPngService.generate_student_graph(@form)
    end
    ch
  end

  def generate_csv
    table = []
    table = ExportCsvService.fill_table(table, @form, @form_questions)
    ExportCsvService.call(table)
  end
end
