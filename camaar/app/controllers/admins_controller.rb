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

  def envio
    @student_templates = Template.where({ coordinator_id: @coordinator.id, draft: false, role: 'discente' })
    @teacher_templates = Template.where({ coordinator_id: @coordinator.id, draft: false, role: 'docente' })

    flash.clear
    teacher_template_id = params[:teacher_template]
    student_template_id = params[:student_template]
    classes_ids = params[:classes_ids]

    commit = params[:commit]
    if classes_ids.present? && commit == 'confirm'
      classes_ids.each do |subject_class_id|
        if !(teacher_template_id.present? or student_template_id.present?)
          flash[:warning] = 'Selecione pelo menos um template para envio.'
        else
          if teacher_template_id.present?
            teacher_template = Template.find_by(id: teacher_template_id, draft: false)
            teacher_form = Form.new(
              role: teacher_template.role,
              name: teacher_template.name,
              coordinator_id: teacher_template.coordinator_id,
              subject_class_id:
            )

            if teacher_form.save
              teacher_template_questions = TemplateQuestion.where({ template_id: teacher_template.id })
              teacher_template_questions.each do |question|
                FormQuestion.create({
                                      title: question.title,
                                      body: question.body,
                                      question_type: question.question_type,
                                      form_id: teacher_form.id
                                    })
              end

              flash[:success] =
                "O formulário para o professor da turma #{SubjectClass.find_by(id: subject_class_id).name} foi criado com sucesso."
            end
          end

          if student_template_id.present?
            student_template = Template.find_by(id: student_template_id)
            student_form = Form.new(
              name: student_template.name,
              coordinator_id: student_template.coordinator_id,
              subject_class_id:
            )

            if student_form.save
              student_template_questions = TemplateQuestion.where({ template_id: student_template.id })
              student_template_questions.each do |question|
                FormQuestion.create({
                                      title: question.title,
                                      body: question.body,
                                      question_type: question.question_type,
                                      form_id: student_form.id
                                    })
              end

              flash[:success] =
                "O formulário para os alunos da turma #{SubjectClass.find_by(id: subject_class_id).name} foi criado com sucesso."
            end
          end
        end
      end
    else
      flash[:warning] = 'Selecione as turmas para envio.'
    end
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

    answers = []
    @forms.each do |form|
      @form_questions = FormQuestion.where(form_id: form.id)

      occupation = form.role
      case occupation
      when 'discente'
        answers = StudentAnswer.where(form_question_id: @form_questions.pluck(:id)) if @form_questions
      when 'docente'
        answers = TeacherAnswer.where(form_question_id: @form_questions.pluck(:id)) if @form_questions
      end

      # if answers.any?
      #   answered_forms << form
      # end
    end
    # @forms = answered_forms

    @form = Form.find_by_id(params[:form_id]) if params[:form_id]
    @form_questions = FormQuestion.where(form_id: @form.id) if @form

    student_answers = StudentAnswer.where(form_question_id: @form_questions.pluck(:id)) if @form_questions
    teacher_answers = TeacherAnswer.where(form_question_id: @form_questions.pluck(:id)) if @form_questions

    if params[:export].present? and !((student_answers.present? or teacher_answers.present?))
      flash[:warning] = 'O formulário não possui respostas'
      redirect_to '/admins/results'
    else
      case params[:export]
      when 'csv'
        export_to_csv
      when 'graph'
        @form = Form.find_by_id(params[:form_id])
        @form_questions = FormQuestion.where(form_id: @form.id)
        export_to_png
      end
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

    @form_questions.each do |question|
      answers = if @form.role == 'discente'
                  StudentAnswer.where(form_question_id: question.id)
                else
                  TeacherAnswer.where(form_question_id: question.id)
                end

      question_body = JSON.parse(question.body)
      answers.each do |answ|
        answer_body = JSON.parse(answ.answers)['answers']

        case question.question_type
        when 'text'
          resumo[question.title] ||= []
          resumo[question.title] << answer_body
        when 'multiple_choice'
          resumo[question.title] ||= {}
          question_body['options'].each do |option|
            resumo[question.title][option[1]] ||= 0 if option[1] != ''
          end

          answer_body.each do |k, selected|
            resumo[question.title][question_body['options'][k]] += 1 if selected
          end
        end
      end
    end

    resumo
  end

  def export_to_csv
    csv_string = generate_csv
    csv_data = CSV.parse(csv_string, headers: true)

    file_path = Rails.root.join('export', "#{@form.id}_#{@form.name}_results.csv")
    directory_path = File.dirname(file_path)
    FileUtils.mkdir_p(directory_path) unless File.directory?(directory_path)

    CSV.open(file_path, 'w') do |csv|
      csv << csv_data.headers

      csv_data.each do |row|
        csv << row
      end
    end

    send_file file_path, filename: "#{@form.id}_#{@form.name}.csv".gsub(' ', '_').downcase, type: 'text/csv'
  end

  def export_to_png
    graph = generate_graph

    filename = @form.name + '.png'
    file_path = File.join('export', filename)
    graph.render_png(file_path)
    send_file file_path, filename: "#{@form.id}_#{@form.name}.png".gsub(' ', '_').downcase, type: 'image/png'
  end

  def generate_graph
    if @form.role == 'discente'
      enrollments = Enrollment.where(subject_class_id: @form.subject_class_id)
      number_of_students = enrollments.distinct.count(:student_id)
      num_answers = StudentAnswer.where(student_id: enrollments.distinct.pluck(:student_id)).count
      num_absents = number_of_students - num_answers
      p = Rdata.new
      p.add_point([num_answers, num_absents], 'Serie1')
      p.add_point(%w[Respostas Ausências], 'Serie2')
      p.add_all_series
      p.set_abscise_label_serie('Serie2')

      ch = Rchart.new(300, 200)
      ch.set_font_properties('tahoma.ttf', 8)

      ch.draw_filled_rounded_rectangle(7, 7, 293, 193, 5, 240, 240, 240)
      ch.draw_rounded_rectangle(5, 5, 295, 195, 5, 230, 230, 230)

      # Draw the pie chart
      ch.antialias_quality = 0
      ch.set_shadow_properties(2, 2, 200, 200, 200)
      ch.draw_flat_pie_graph_with_shadow(p.get_data, p.get_data_description, 120, 100, 60, Rchart::PIE_PERCENTAGE, 8)
      ch.clear_shadow

      ch.draw_pie_legend(210, 35, p.get_data, p.get_data_description, 250, 250, 250)
    elsif @form.role == 'docente'
      form_questions = FormQuestion.where(form_id: @form.id)
      text_questions = form_questions.where(question_type: 'text').count
      multiple_choice_questions = form_questions.where(question_type: 'multiple_choice').count

      p = Rdata.new
      p.add_point([text_questions, multiple_choice_questions], 'Serie1')
      p.add_point(%w[Texto Múltipla-Escolha], 'Serie2')

      p.add_all_series
      p.set_abscise_label_serie('Serie2')

      ch = Rchart.new(300, 200)
      ch.set_font_properties('tahoma.ttf', 8)
      ch.draw_filled_rounded_rectangle(7, 7, 293, 193, 5, 240, 240, 240)
      ch.draw_rounded_rectangle(5, 5, 295, 195, 5, 230, 230, 230)

      # Draw the pie chart
      ch.antialias_quality = 0
      ch.set_shadow_properties(2, 2, 200, 200, 200)
      ch.draw_flat_pie_graph_with_shadow(p.get_data, p.get_data_description, 120, 100, 60, Rchart::PIE_PERCENTAGE, 8)
      ch.clear_shadow

      ch.draw_pie_legend(210, 35, p.get_data, p.get_data_description, 250, 250, 250)
    end
    ch
  end

  def generate_csv
    table = []
    @form_questions.each do |question|
      answers = if @form.role == 'discente'
                  StudentAnswer.where(form_question_id: question.id)
                else
                  TeacherAnswer.where(form_question_id: question.id)
                end

      line = [question.title]

      answers.each do |answ|
        question_body = JSON.parse(FormQuestion.find_by_id(answ.form_question_id).body)
        answer_body = JSON.parse(answ.answers)['answers']

        case question.question_type
        when 'text'
          line << answer_body
        when 'multiple_choice'
          answer_body.each do |num, selected|
            line << question_body['options'][num] if selected
          end
        end
      end
      table << line
    end

    head = ['Questão']
    (table[0].length - 1).times do |i|
      head << "Resposta #{i + 1}"
    end
    table.unshift(head)

    CSV.generate do |csv|
      table.each do |row|
        csv << row
      end
    end
  end
end
