class SummaryController < AdminsController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_admin_data
  before_action :load
  # Método que funciona como um "setup" dos parâmetros relacionados ao resumo das respostas de um formulário, configurando
  # os atributos necessários para a interação MVC.
  def summary
    form
    form_questions
    summary?
  end

  # Método que executa métodos essenciais para receber o número de respostas do formulário e o número de questões,
  # além de possuir uma instância de objeto da classe Results que é responsável por gerar um resumo das questões
  # respondidas do formulário em questão
  def summary?
    total_number
    answered_number
    @form_summary = Results.new.generate_summary(form_questions, form)
  end

  # Método que recupera o respectivo formulário acessado
  def form
    @form = Form.find_by_id(params[:id])
  end

  # Método que recupera as questões do respectivo formulário acessado
  def form_questions
    @form_questions = FormQuestion.where(form_id: form.id)
  end

  # Método que recupera o total quantitativo dos alunos/professores que podem responder o respectivo formulário acessado
  def total_number
    @total_number = form.role == 'discente' ? Enrollment.where(subject_class_id: form.subject_class_id).length : 1
  end

  # Método que recupera o total quantitativo dos alunos/professores que responderam o respectivo formulário acessado
  def answered_number
    @answered_number = StudentAnswer.where(form_question_id: form_questions[0].id).length
  end
end
