# A classe DispatchController advém da classe AdminsController gerencia as principais ações relacionadas
# à visualização de resultados provenientes das respostas de formulários por alunos e/ou professores

class DispatchController < AdminsController
   # Método que funciona como setup para o envio de templates/formulários. O método em questão configura os templates de
  # professor, aluno, as classes e verifica se houve a requisição para enviar um template/formulário.
  def setup_envio(coordinator_id)
    @student_templates = Template.where({ coordinator_id:, draft: false, role: 'discente' })
    @teacher_templates = Template.where({ coordinator_id:, draft: false, role: 'docente' })
    flash.clear
    [params[:teacher_template], params[:student_template], params[:classes_ids], params[:commit]]
  end

  # Método que recebe uma requisição para enviar um template/formulário. Caso haja sucesso ou erro, serão printadas
  # as respectivas mensagens na página do administrador. Há o uso de uma instância da classe Dispatch, responsável por executar
  # os métodos de envio
  def envio
    teacher_template_id, student_template_id, classes_ids, commit = setup_envio(coordinator.id)
    dispatch = Dispatch.new
    case dispatch.commit?(classes_ids, commit)
    when true
      dispatch.execute(classes_ids, student_template_id, teacher_template_id).each do |item|
        flash[item[0].to_sym] = item[1]
      end
    when false
      flash[:warning] = 'Selecione as turmas para envio.'
    end
  end
end
