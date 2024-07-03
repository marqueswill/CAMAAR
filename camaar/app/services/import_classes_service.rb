# Serviço responsável por realizar a importação de classes conforme ações
# do administrador.
class ImportClassesService
  # Método que recebe uma lista de classes e realiza importação.
  def self.call(classes)
    classes.each do |subject_class|
      subject = subject_class['code']
      initials = subject.gsub(/[^a-zA-Z]/, '')
      keys = { subject:,
               code: subject_class['class']['classCode'],
               semester: subject_class['class']['semester'] }
      imported_data = {
        name: subject_class['name'],
        schedule: subject_class['class']['time'],
        department_id: Department.find_by(initials:).id
      }

      db_subject_class = SubjectClass.find_by(keys)

      if db_subject_class
        db_subject_class.update(
          imported_data
        )
      else
        SubjectClass.create(
          keys.merge(imported_data)
        )
      end
    end
  end
end
