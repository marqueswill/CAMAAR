# Classe que representa uma instância de classe que existe na família de AdminsController para exportar estatísticas e gráficos.
# Efetua as chamadas de serviços para exportar as respostas em CSV e exportar gráficos.

class Export < AdminsController
  # Método que gerencia as requisições para exportar os resultados de algum formulário.
  # Caso a requisição seja para 'csv', será gerado um arquivo CSV contendo as respostas do formulário.
  # Caso a requisição seja para 'graph', será gerado um arquivo png contendo um gráfico relacionado às estatísticas do form.

  def execute(mode, form, form_questions)
    form_id = form.id
    form_name = form.name
    case mode
    when 'csv'
      [ExportService.execute_csv(form, form_questions), "#{form_id}_#{form_name}.csv".gsub(' ', '_').downcase,
       'text/csv']
    when 'graph'
      [ExportService.export_to_png(form), "#{form_id}_#{form_name}.png".gsub(' ', '_').downcase, 'image/png']
    end
  end
end
