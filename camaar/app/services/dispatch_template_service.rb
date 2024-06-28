class DispatchTemplateService
  def self.dispatch_student(student_template,student_form)
    student_template_questions = TemplateQuestion.where({ template_id: student_template.id })
    student_template_questions.each do |question|
      FormQuestion.create({
                            title: question.title,
                            body: question.body,
                            question_type: question.question_type,
                            form_id: student_form.id
                          })
    end
  end

  def self.dispatch_teacher(teacher_template,teacher_form)
    teacher_template_questions = TemplateQuestion.where({ template_id: teacher_template.id })
    teacher_template_questions.each do |question|
      FormQuestion.create({
                            title: question.title,
                            body: question.body,
                            question_type: question.question_type,
                            form_id: teacher_form.id
                          })
    end
  end

  def self.dispatch(role,template,form)
    case role
    when 'teacher'
      DispatchTemplateService.dispatch_teacher(template, form)
    when 'student'
      DispatchTemplateService.dispatch_student(template, form)
    end
  end
end
