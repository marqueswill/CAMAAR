# A classe ResultsController advém da classe AdminsController gerencia as principais ações relacionadas
# à visualização de resultados provenientes das respostas de formulários por alunos e/ou professores

class ResultsController < AdminsController

  # Método que gerencia as requisições para a visualização e obtenção de resultados para o administrador, que consistem
  # sumariamente nas respostas de alunos e/ou professores a um formulário previamente submetido.
  def results
    ResultsService.fill_answers(forms)
    form_id = params[:form_id]

    setup_results(form_id) if form_id
  end

  # Método que funciona como setup para a visualização de resultados de formulários respondidos.
  # O método em questão configura os formulários e as questões, e verifica se houve ou não respostas.
  def setup_results(form_id)
    form = Form.find_by_id(form_id)
    form_questions = FormQuestion.where(form_id:)

    mode = params[:export]
    results?(mode, form, form_questions)
  end

  # Método auxiliar que age de forma a verificar se houve ou não respostas para um formulário acessado na view de resultados.
  # O método em questão verifica se houve ou não respostas e, caso seja requerido, configura a exportação destas.
  def results?(mode, form, form_questions)
    if mode.present? && Results.new.answers?(form_questions)
      flash[:warning] = 'O formulário não possui respostas'
      redirect_to '/admins/results'
    else
      file, filename, type = Export.new.execute(mode, form, form_questions)
      send_file file, filename:, type:
    end
  end
end
