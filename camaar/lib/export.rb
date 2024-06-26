class Export < AdminsController
  def fill_csv(form_id,form_name, csv_data)
    file_path = Rails.root.join('export', "#{form_id}_#{form_name}_results.csv")
    directory_path = File.dirname(file_path)
    FileUtils.mkdir_p(directory_path) unless File.directory?(directory_path)
    ExportCsvService.csv?(file_path,csv_data)
    file_path
  end

  def export_to_csv(form,form_questions)
    form_id, form_name = [form.id,form.name]
    csv_string = generate_csv(form,form_questions)
    CSV.parse(csv_string, headers: true)
  end


  # def export_to_png(form)
  #   name,id,graph,filename = [form.name,form.id,generate_graph(form),"#{name}.png"]
  #   ExportPngService.call(filename, graph)
  # end

  # def generate_graph(form)
  #   case form.role
  #   when 'discente'
  #     ExportPngService.generate_teacher_graph(form)
  #   when 'docente'
  #     ExportPngService.generate_student_graph(form)
  #   end
  # end

  def generate_csv(form,form_questions)
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
