# A classe SubjectClassControllers gerencia as principais ações do administrador relacionadas às classes do departamento.
# Essa classe inclui a visualização de classes do departamento, além de renderizar erros caso não haja autenticação.

class SubjectClassesController < AdminsController
  def index
    bool, msg = index?

    if bool && !flash[:warning]
      flash[:warning] = msg
      redirect_to "/admins/classes"
    end
  end

  def index?
    unless admin
      return [true, "Admin não encontrado"]
    end

    unless coordinator
      return [true, "Coordenador não encontrado"]
    end

    unless classes.present?
      return [true, "O departamento não possui turmas"]
    end

    [false, ""]
  end
end
