# A classe SubjectClassControllers gerencia as principais ações do administrador relacionadas às classes do departamento.
# Essa classe inclui a visualização de classes do departamento, além de renderizar erros caso não haja autenticação.

class SubjectClassesController < AdminsController
  def index
    @errors = []
    bool, msg = index?

    if bool
      render :'errors/forbidden', status: :forbidden
      @errors << msg
      return
    end

    return unless classes.empty?

    @errors << 'O departamento não possui turmas'
  end

  def index?
    unless admin
      return [true,'Admin não encontrado']
    end

    unless coordinator
      return [true,'Coordenador não encontrado']
    end
    [false,'']
  end

end
