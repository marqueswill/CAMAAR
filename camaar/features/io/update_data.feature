Feature: Update database data

    As a Coordinator
    I want to update the existing database with the current data from SIGAA
    So that I can correct the system's database

    Background: Data has already been imported before

    Scenario: Coordinator attempts to update class data

        Given I am an authenticated Coordinator
        And I am on the "Importar dados" page
        When I click on "Tipos de dados"
        And I choose "Turmas"
        And I click "Upload"
        And I choose a json file
        And I click "Importar"
        And I click on "Sobrescrever dados existentes"
        Then I should be able to update the old data

    Scenario: Coordinator attempts to update members data
        Given Im an authenticated Coordinator
        And I am on the "Importar dados" page
        When I click on "Tipos de dados"
        And I choose "Membros"
        And I click "Upload"
        And I choose a json file
        And I click "Importar"
        And I click on "Sobrescrever dados existentes"
        Then I should be able to replace the old data about members