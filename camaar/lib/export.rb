class Export < AdminsController
  def fill_csv(form_id, form_name, csv_data)
    file_path = Rails.root.join('export', "#{form_id}_#{form_name}_results.csv")
    directory_path = File.dirname(file_path)
    FileUtils.mkdir_p(directory_path) unless File.directory?(directory_path)
    ExportCsvService.csv?(file_path, csv_data)
    file_path
  end

  def export_to_csv(form, form_questions)
    form_id = form.id
    form_name = form.name
    csv_string = generate_csv(form, form_questions)
    CSV.parse(csv_string, headers: true)
  end

  # Método que gerencia as requisições para exportar os resultados de algum formulário.
  # Caso a requisição seja para 'csv', será gerado um arquivo CSV contendo as respostas do formulário.
  # Caso a requisição seja para 'graph', será gerado um arquivo png contendo um gráfico relacionado às estatísticas do form.

  def execute(mode, form, form_questions)
    form_id = form.id
    form_name = form.name
    case mode
    when 'csv'
      [execute_csv(form, form_questions), "#{form_id}_#{form_name}.csv".gsub(' ', '_').downcase, 'text/csv']
    when 'graph'
      [export_to_png(form), "#{form_id}_#{form_name}.png".gsub(' ', '_').downcase, 'image/png']
    end
  end

  def execute_csv(form, form_questions)
    form_id = form.id
    form_name = form.name
    fill_csv(form_id, form_name, export_to_csv(form, form_questions))
  end

  # Método que gerencia as requisições para exportar um gráfico de setores relacionado a algum formulário respondido.
  # O método em questão irá enviar um arquivo png do gráfico ao browser do administrador.
  def export_to_png(form)
    name = form.name
    id = form.id
    graph = generate_graph(form)
    filename = "#{form.name}.png"
    ExportPngService.call(filename, graph)
  end

  def generate_csv(form, form_questions)
    table = []
    table = ExportCsvService.fill_table(table, form, form_questions)
    ExportCsvService.call(table)
  end

  def generate_graph(form)
    case form.role
    when 'discente'
      ExportPngService.generate_teacher_graph(form)
    when 'docente'
      ExportPngService.generate_student_graph(form)
    end
  end
end
