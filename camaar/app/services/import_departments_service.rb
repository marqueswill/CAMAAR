# Serviço responsável por realizar a importação de departamentos conforme ações
# do administrador.
class ImportDepartmentsService
  def self.call(departamentos)
    departamentos.each do |dpto|
      Department.create!(
        id: dpto['id'],
        initials: dpto['initials'],
        name: dpto['name']
      )
    end
  end
end
