class ImportClassesService
  def self.call(_members)
    classes.each do |subject_class|
      initials = subject_class['code'].gsub(/[^a-zA-Z]/, '')
      keys = { subject: subject_class['code'],
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
