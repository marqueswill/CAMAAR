# Classe que representa um serviço da AdminsController de exportar resultados em PNG e CSV.
# Efetua as operações de exportação e solicita operações de outros serviços.
class ExportService
  # Método que gerencia as requisições para exportar um gráfico de setores relacionado a algum formulário respondido.
  # O método em questão irá enviar um arquivo png do gráfico ao browser do administrador.
  def self.export_to_png(form)
    graph = ExportService.generate_graph(form)
    filename = "#{form.name}.png"
    ExportPngService.call(filename, graph)
  end

  def self.generate_graph(form)
    case form.role
    when 'discente'
      ExportPngService.generate_teacher_graph(form)
    when 'docente'
      ExportPngService.generate_student_graph(form)
    end
  end

  def self.fill_csv(form_id, form_name, csv_data)
    file_path = Rails.root.join('export', "#{form_id}_#{form_name}_results.csv")
    directory_path = File.dirname(file_path)
    FileUtils.mkdir_p(directory_path) unless File.directory?(directory_path)
    ExportCsvService.csv?(file_path, csv_data)
    file_path
  end

  def self.execute_csv(form, form_questions)
    form_id = form.id
    form_name = form.name
    fill_csv(form_id, form_name, export_to_csv(form, form_questions))
  end

  def self.generate_csv(form, form_questions)
    table = []
    table = ExportCsvService.fill_table(table, form, form_questions)
    ExportCsvService.call(table)
  end

  def self.export_to_csv(form, form_questions)
    csv_string = generate_csv(form, form_questions)
    CSV.parse(csv_string, headers: true)
  end
end
