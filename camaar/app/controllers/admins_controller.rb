require 'json'
require 'rchart'
require 'csv'
# A classe AdminsController gerencia as principais ações relacionadas às funcionalidades do administrador.
# Essa classe inclui a importação de dados, a exportação de resultados em CSV e Gráficos, visualização de
# respostas de formulários, gerenciamento de templates etc.
class AdminsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_admin_data
  before_action :load

  # Atributos para evitar o uso de variáveis de instância
  attr_reader :forms

  # Carrega os templates e as classes do departamento
  def load
    coord_id = coordinator.id
    @templates = Template.where(coordinator_id: coord_id, draft: false)
    @forms = Form.where(coordinator_id: coord_id)
  end

  # Método que recebe uma requisição para importar algum dado a partir de um json. Caso haja sucesso ou erro, serão printadas
  # as respectivas mensagens na página do administrador. Há o uso de uma instância da classe Import, responsável por executar
  # os métodos de importação.
  def import
    @errors = []
    json = JSON.parse(File.read(params[:admin_import][:file].tempfile.path))
    symbol, msg = Import.new.import_data(params[:select_data], json, current_admin.email)
    flash[symbol.to_sym] = msg
    redirect_to '/admins/import'
  end

end
