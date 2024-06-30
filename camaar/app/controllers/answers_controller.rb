require "csv"

# A classe AnswersController gerencia as funcionalidas referentes às respostas dos formulários.
# Essa classe contém os métodos públicos responsáveis por responder os formulários de usuáriios, sejam
# alunos ou professores. Ela processa e salva as respostas enviadas via requisição POST na forma de um
# formulário HTML.
# Também contém métodos protegidos e instâncias de classes auxiliares que são responsáveis por realizar as partes mais lógicas do código.

class AnswersController < ApplicationController
  before_action :set_user_data
  before_action :validate_answers, only: :create
  layout "user"

  # Método para o qual o recurso 'answers' é mapeado diretamente. Através de serviços e métodos
  # auxiliares, é capaz de registrar as respostas aos formulários no banco
  def create
    form = Form.find_by_id(params[:form_id])
    @form = form if form
    path, warn = Answers.new.submit_answers(params[:answers], params[:commit], current_user, form)
    if warn
      flash[:warning] = @errors
    end
    redirect_to path
  end

  protected

  # Método que toma as respostas das perguntas e verifica se foram respondidas. Caso não tenham
  # sido, é enviado um flash exigindo que o usuário responda e redireciona pra view edit, que é
  # responsável por gerar a UI em que o usuário deve responder o formulário
  def validate_answers
    form = Form.find_by_id(params[:form_id])
    answers_params = params[:answers]

    if answers_params.present?
      answers_params.each do |id, answ|
        if answ.empty?
          flash[:error] = "Responda todas questões."
          redirect_to edit_form_path(form) and return
        end
      end
    end
  end

end
