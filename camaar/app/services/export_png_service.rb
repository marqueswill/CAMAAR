class ExportPngService
  def self.call(filename, graph)
    file_path = File.join('export', filename)
    graph.render_png(file_path)
    file_path
  end

  def self.generate_teacher_graph(form)
    enrollments = Enrollment.where(subject_class_id: form.subject_class_id)
    number_of_students = enrollments.distinct.count(:student_id)
    num_answers = StudentAnswer.where(student_id: enrollments.distinct.pluck(:student_id)).count
    num_absents = number_of_students - num_answers
    p = Rdata.new
    p.add_point([num_answers, num_absents], 'Serie1')
    p.add_point(%w[Respostas Ausências], 'Serie2')
    generate_graph(p)
  end

  def self.generate_graph(p)
    p.add_all_series
    p.set_abscise_label_serie('Serie2')

    ch = Rchart.new(300, 200)
    ch.set_font_properties('tahoma.ttf', 8)

    ch.draw_filled_rounded_rectangle(7, 7, 293, 193, 5, 240, 240, 240)
    ch.draw_rounded_rectangle(5, 5, 295, 195, 5, 230, 230, 230)

    ch.antialias_quality = 0
    ch.set_shadow_properties(2, 2, 200, 200, 200)
    ch.draw_flat_pie_graph_with_shadow(p.get_data, p.get_data_description, 120, 100, 60, Rchart::PIE_PERCENTAGE, 8)
    ch.clear_shadow

    ch.draw_pie_legend(210, 35, p.get_data, p.get_data_description, 250, 250, 250)
    ch
  end

  def self.generate_student_graph(form)
    form_questions = FormQuestion.where(form_id: form.id)
    text_questions = form_questions.where(question_type: 'text').count
    multiple_choice_questions = form_questions.where(question_type: 'multiple_choice').count

    p = Rdata.new
    p.add_point([text_questions, multiple_choice_questions], 'Serie1')
    p.add_point(%w[Texto Múltipla-Escolha], 'Serie2')

    generate_graph(p)
  end
end
