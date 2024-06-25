class Import < AdminsController
  def import_data(selected_data, json,admin_email)
    case selected_data
    when '1'
      import_members(json)
    when '2'
      import_classes(json)
    when '3'
      import_departments(json,admin_email)
    end
  end

  def import_departments(file,admin_email)
    if root?(admin_email)
      ImportDepartmentsService.call(file)
      ['notice','Departamentos importados com sucesso']
    else
      ['error','Você não é admin ROOT']
    end
  end

  def root?(admin_email)
    root_dpto = Department.find_by(initials: 'ROOT')
    return false if root_dpto.nil?

    root_cord = Coordinator.find_by(department_id: root_dpto.id)
    admin_email == root_cord&.email
  end

  def import_classes(file)
    ImportClassesService.call(file)
    ['notice','Turmas importadas com sucesso']
  end

  def import_members(file)
    ImportMembersService.call(file)
    ['notice','Membros importados com sucesso']
  end
end
