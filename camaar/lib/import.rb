# Classe que representa uma instância de classe que existe na família de AdminsController para
# importar membros de turmas, turmas e departamentos do SIGAA.
class Import < AdminsController
  def import_data(selected_data, json, admin_email)
    case selected_data
    when '1'
      ImportService.import_members(json)
    when '2'
      ImportService.import_classes(json)
    when '3'
      ImportService.import_departments(json, admin_email)
    end
  end
end
