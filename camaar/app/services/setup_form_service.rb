class SetupFormService
  def self.setup_student_form(student_template_id, subject_class_id)
    student_template = Template.find_by(id: student_template_id, draft: false)
    student_form = Form.new(
      name: student_template.name,
      coordinator_id: student_template.coordinator_id,
      subject_class_id:
    )
    [student_form, student_template]
  end

  def self.setup_teacher_form(teacher_template_id, subject_class_id)
    teacher_template = Template.find_by(id: teacher_template_id, draft: false)
    teacher_form = Form.new(
      role: teacher_template.role,
      name: teacher_template.name,
      coordinator_id: teacher_template.coordinator_id,
      subject_class_id:
    )
    [teacher_form,teacher_template]
  end
end
