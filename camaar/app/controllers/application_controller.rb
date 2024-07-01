# A classe AplicationController é a classe responsável por gerenciar dados do usuário logado.
# De acordo com o tipo de usuário logado, a ApplicationController busca os dados do usuário e os disponibiliza para as views.
# É uma controller base do rails e gerencia as principais requisições a serem herdadas pelas demais controllers.

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :verify_authenticity_token

  # Método que define o caminho para onde o usuário será redirecionado após o login.
  # Caso o usuário seja um administrador, ele será redirecionado para a página de templates.
  # Caso o usuário seja um aluno, ele será redirecionado para a página de formulários.

  def after_sign_in_path_for(_resource)
    if admin_signed_in?
      templates_path
    elsif user_signed_in?
      '/users/forms'
    else
      root_path
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password]
    devise_parameter_sanitizer.permit :define, keys: [:email]
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  # Método que define os dados de um administrador logado.
  def set_admin_data
    if current_admin
      admin
      coordinator
    end
    return unless coordinator

    department
    classes
    teachers
    templates
  end

  # Método auxiliar que define qual administrador está logado.
  def admin
    @admin = current_admin
  end

  # Método auxiliar que define qual coordenador está logado.
  def coordinator
    @coordinator = Coordinator.find_by({ email: current_admin.email })
  end

  # Método auxiliar que define o departamento do coordenador logado.
  def department
    @department = Department.find_by_id(coordinator.department_id)
  end

  # Método auxiliar que define as classes do departamento do coordenador logado.
  def classes
    @classes = SubjectClass.where(department_id: coordinator.department_id)
  end

  # Método auxiliar que define os professores do departamento do coordenador logado.
  def teachers
    @teachers = Teacher.where(department_id: coordinator.department_id)
  end

  # Método auxiliar que define os templates do coordenador logado.
  def templates
    templates = Template.where(coordinator_id: coordinator.id)
    templates ||= []
    @templates = templates
    @errors = []

    return unless templates.empty?

    @errors << 'Não foram encontrados templates'
  end

  def set_errors
    @errors = { primary: [],
                secondary: [],
                sucess: [],
                danger: [],
                warning: [],
                info: [],
                light: [],
                dark: [] }
  end

  # Método que define os dados de um usuário logado de acordo com o tipo de usuário.
  def set_user_data
    student?
    teacher?
  end

  # Método auxiliar que define os dados de um professor logado.
  def teacher?
    teacher = Teacher.find_by(email: current_user.email)
    return unless teacher

    @teacher = teacher
    current_user.occupation = teacher.occupation
    current_user.name = teacher.name.split.first.capitalize
    @department = Department.find_by_id(teacher.department_id) if teacher
  end

  # Método auxiliar que define os dados de um aluno logado.
  def student?
    student = Student.find_by(email: current_user.email)
    return unless student

    @student = student
    current_user.occupation = student.occupation
    current_user.name = student.name.split.first.capitalize
    @department = Department.find_by(initials: student.course.split('/').last)
  end
end
