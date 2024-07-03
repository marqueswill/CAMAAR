# Classe que representa um serviço da AdminsController de importar membros.
# Efetua as operações de importação de classes, professores e alunos.
class ImportService
  def self.root?(admin_email)
    root_dpto = Department.find_by(initials: 'ROOT')
    return false if root_dpto.nil?

    root_cord = Coordinator.find_by(department_id: root_dpto.id)
    admin_email == root_cord&.email
  end

  def self.import_departments(file, admin_email)
    if root?(admin_email)
      ImportDepartmentsService.call(file)
      ['notice', 'Departamentos importados com sucesso']
    else
      ['error', 'Você não é admin ROOT']
    end
  end

  def self.import_classes(file)
    ImportClassesService.call(file)
    ['notice', 'Turmas importadas com sucesso']
  end

  def self.import_members(file)
    ImportMembersService.call(file)
    ['notice', 'Membros importados com sucesso']
  end
end
