# A classe ApplicationControler é uma controller base do rails e gerencia as principais requisições
# a serem herdadas pelas demais controllers

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :verify_authenticity_token

  def after_sign_in_path_for(_resource)
    if admin_signed_in?
      templates_path
    elsif user_signed_in?
      "/users/forms"
    else
      root_path
    end
  end

  protected

  def configure_permitted_parameters
    added_attrs = %i[email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password]
    devise_parameter_sanitizer.permit :define, keys: [:email]
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def set_admin_data
    if current_admin
      admin
      coordinator
    end
    if coordinator
      department
      classes
      teachers
      templates
    end
  end

  def admin
    @admin = current_admin
  end
  def coordinator
    @coordinator = Coordinator.find_by({ email: current_admin.email })
  end

  def department
    @department = Department.find_by_id(coordinator.department_id)
  end

  def classes
    @classes = SubjectClass.where(department_id: coordinator.department_id)
  end

  def teachers
    @teachers = Teacher.where(department_id: coordinator.department_id)
  end

  def templates
    templates = Template.where(coordinator_id: coordinator.id)
    templates ||= []
    @templates = templates
    @errors = []

    if templates.empty?
      @errors << "Não foram encontrados templates"
    end
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

  def set_user_data
    student?
    teacher?
  end

  def teacher?
    teacher = Teacher.find_by(email: current_user.email)
    if teacher
      @teacher = teacher
      current_user.occupation = teacher.occupation
      current_user.name = teacher.name.split.first.capitalize
      @department = Department.find_by_id(teacher.department_id) if teacher
    end
  end

  def student?
    student = Student.find_by(email: current_user.email)
    if student
      @student = student
      current_user.occupation = student.occupation
      current_user.name = student.name.split.first.capitalize
      @department = Department.find_by(initials: student.course.split("/").last)
    end
  end

end
