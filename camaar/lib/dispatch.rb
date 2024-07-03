# Classe que representa uma instância de classe que existe na família de AdminsController para
# enviar templates/formulários para alunos e/ou professores
class Dispatch
  # Método para enviar templates/formulários pras turmas.
  def execute(classes_ids, student_template_id = nil, teacher_template_id = nil)
    results = []
    classes_ids.each do |subject_class_id|
      results << dispatch?(teacher_template_id, student_template_id, subject_class_id)
    end
    results
  end

  # Método para verificar os formulários de acordo com o tipo (professor ou aluno).
  def dispatch?(teacher_template_id, student_template_id, subject_class_id)
    teacher_present = teacher_template_id.present?
    student_present = student_template_id.present?
    if !teacher_present && !student_present
      ['warning', 'Selecione pelo menos um template para envio.']
    else
      [(dispatch_template(teacher_template_id, subject_class_id, 'teacher') if teacher_present),
       (if student_present
          dispatch_template(
            student_template_id, subject_class_id, 'student'
          )
        end)].compact.flatten
    end
  end

  # Método para enviar template/formulário pra uma turma específica.
  def dispatch_template(template_id, subject_class_id, role)
    form, template = Dispatch.forms?(role, template_id, subject_class_id)

    return unless form.save

    DispatchTemplateService.dispatch(role, template, form)

    ['success',
     "O formulário para #{role == 'teacher' ? 'o professor' : 'os alunos'} da turma #{SubjectClass.find_by(id: subject_class_id).name} foi criado com sucesso.<br>"]
  end

  # Método para configurar os formulários de acordo com o role (professor ou aluno).
  def self.forms?(role, template_id, subject_class_id)
    case role
    when 'teacher'
      form, template = SetupFormService.setup_teacher_form(template_id, subject_class_id)
    when 'student'
      form, template = SetupFormService.setup_student_form(template_id, subject_class_id)
    else
      return
    end
    [form, template]
  end
end
