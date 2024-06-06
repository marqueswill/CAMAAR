require 'rails_helper'
require 'gruff'

RSpec.feature 'Export Graph', type: :feature do
  describe 'exporting answers as graph' do
    it 'should export a graph containing answers % by students' do
      # visit '/users/login'
      # user = create(:user)
      # expect(page).to have_content 'Bem vindo ao'
      # expect(page).to have_content 'CAMAAR'
      # fill_in 'email', with: user.email
      # fill_in 'password', with: user.password
      # click_button 'Confirmar'
      # expect(page).to have_content 'Formulários Pendentes'
      graph = Gruff::Pie.new
      graph.title = "Respostas do Formulário"

      FactoryBot.define do
        factory :coordinator do
          sequence(:name) { |n| "Coordinator #{n}" }
          admin {}
        end
        factory :subject_class do
          sequence(:name) { |n| "Subject Class #{n}" }
        end
      end

      FactoryBot.define do
        factory :department do
          sequence(:name) { |n| "Department #{n}" }
        end

      end

      department1 = create(:department)

      admin1 = create(:admin)

      student1 = create(:student, :student1)
      student2 = create(:student, :student2)
      student3 = create(:student, :student3)
      student4 = create(:student, :student4)

      coordinator1 = create(:coordinator)

      subject_class1 = create(:subject_class)
      subject_class2 = create(:subject_class)
      subject_class3 = create(:subject_class)

      form1 = create(:form, :form1, coordinator: coordinator1, subject_class: subject_class1)
      form2 = create(:form, :form2, coordinator: coordinator2, subject_class: subject_class2)
      form3 = create(:form, :form3, coordinator: coordinator3, subject_class: subject_class3)


      answ1 = create(:student_answer, :student_answers1)
      answ2 = create(:student_answer, :student_answers2)
      answ3 = create(:student_answer, :student_answers3)

      graph.data 'Total de alunos', Student.count
      graph.data 'Total de respostas', StudentAnswer.where(form_id: 0).count
      graph.write('pie_graph.png')

    end
  end

end