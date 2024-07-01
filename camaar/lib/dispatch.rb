class Dispatch < AdminsController
  def execute(classes_ids, student_template_id = nil, teacher_template_id = nil)
    results = []
    classes_ids.each do |subject_class_id|
      results << dispatch?(teacher_template_id, student_template_id, subject_class_id)
    end
    results
  end

  def commit?(classes_ids, commit)
    if classes_ids.present? && commit == "confirm"
      return true
    else
      return false
    end
  end

  def dispatch?(teacher_template_id, student_template_id, subject_class_id)
    teacher_present, student_present = [teacher_template_id.present?, student_template_id.present?]
    if !teacher_present && !student_present
      ["warning", "Selecione pelo menos um template para envio."]
    else
      [(dispatch_template(teacher_template_id, subject_class_id, "teacher") if teacher_present), (dispatch_template(student_template_id, subject_class_id, "student") if student_present)].compact.flatten
    end
  end

  def dispatch_template(template_id, subject_class_id, role)
    form, template = forms?(role, template_id, subject_class_id)

    return unless form.save

    DispatchTemplateService.dispatch(role, template, form)

    ["success", "O formulário para #{role == "teacher" ? "o professor" : "os alunos"} da turma #{SubjectClass.find_by(id: subject_class_id).name} foi criado com sucesso.<br>"]
  end

  def forms?(role, template_id, subject_class_id)
    case role
    when "teacher"
      form, template = SetupFormService.setup_teacher_form(template_id, subject_class_id)
    when "student"
      form, template = SetupFormService.setup_student_form(template_id, subject_class_id)
    else
      return
    end
    [form, template]
  end
end
