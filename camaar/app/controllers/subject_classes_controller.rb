# A classe SubjectClassControllers gerencia as principais ações do administrador relacionadas às classes do departamento.
# Essa classe inclui a visualização de classes do departamento, além de renderizar erros caso não haja autenticação.

class SubjectClassesController < AdminsController
  def index
    bool, msg = index?

    return unless bool && !flash[:warning]

    if msg == 'O departamento não possui turmas'
      flash[:warning] = msg
      return redirect_to '/admins/classes'
    end
    render :'errors/forbidden', status: :forbidden
  end

  def index?
    return [true, 'Admin não encontrado'] unless admin

    return [true, 'Coordenador não encontrado'] unless coordinator

    return [true, 'O departamento não possui turmas'] unless classes.present?

    [false, '']
  end
end
