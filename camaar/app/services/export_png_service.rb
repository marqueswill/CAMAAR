# Classe que representa um serviço da AdminsController de exportar gráficos em png.
# Efetua as operações de exportação de estatísticas referentes a respostas de formulários de
# alunos e professores.
class ExportPngService
  def self.call(filename, graph)
    file_path = File.join('export', filename)
    graph.render_png(file_path)
    file_path
  end

  def self.generate_student_graph(form)
    num_answers, num_absents = answers?(form)
    graph = Rdata.new
    graph.add_point([num_answers, num_absents], 'Serie1')
    graph.add_point(%w[Respostas Ausências], 'Serie2')
    generate_graph(graph)
  end

  def self.answers?(form)
    enrollments = Enrollment.where(subject_class_id: form.subject_class_id)
    distinct_classes = enrollments.distinct
    number_of_students = distinct_classes.count(:student_id)
    num_answers = StudentAnswer.where(student_id: distinct_classes.pluck(:student_id)).count
    [num_answers, (number_of_students - num_answers)]
  end

  def self.generate_graph(graph)
    graph.add_all_series
    graph.set_abscise_label_serie('Serie2')

    chart = Rchart.new(300, 200)
    chart.set_font_properties('tahoma.ttf', 8)

    chart.draw_filled_rounded_rectangle(7, 7, 293, 193, 5, 240, 240, 240)
    chart.draw_rounded_rectangle(5, 5, 295, 195, 5, 230, 230, 230)

    chart.antialias_quality = 0
    chart.set_shadow_properties(2, 2, 200, 200, 200)

    graph_data = graph.get_data
    graph_description = graph.get_data_description

    chart.draw_flat_pie_graph_with_shadow(graph_data, graph_description, 120, 100, 60, Rchart::PIE_PERCENTAGE, 8)
    chart.clear_shadow

    chart.draw_pie_legend(210, 35, graph_data, graph_description, 250, 250, 250)
    chart
  end

  def self.generate_teacher_graph(form)
    form_questions = FormQuestion.where(form_id: form.id)
    text_questions = form_questions.where(question_type: 'text').count
    multiple_choice_questions = form_questions.where(question_type: 'multiple_choice').count

    graph = Rdata.new
    graph.add_point([text_questions, multiple_choice_questions], 'Serie1')
    graph.add_point(%w[Texto Múltipla-Escolha], 'Serie2')

    generate_graph(graph)
  end
end
