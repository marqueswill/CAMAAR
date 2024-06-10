Feature: Create a form for students of a class
    As a Coordinator
    I want to choose to create a form for the students of the classes I choose
    So that I can evaluate the performance of the classes in the current semester

    Background: I am a Coordinator on the templates page
        Given I am an authenticated Coordinator from the "DEPTO CIÊNCIAS DA COMPUTAÇÃO"
        Given that I imported classes for the "DEPTO CIÊNCIAS DA COMPUTAÇÃO"
        When I follow "Envio"
        Then I should be on the "Envio" page
        And I expect to see "Selecione as opções para envio"
        Given that I created the following templates:
            | Template 1 | teacher |
            | Template 2 | student |

        When I select "Professores" from "Destinatário"
        Then I expect to see "Selecione template para os professores"

        When I select "Template 1" from "Selecione o Template"
        Then I expect to see "Template 1"

        Then I expect to see "Selecione as turmas"
        And I expect to see the following classes:
            | name                    | semester | subject | classCode | schedule |
            | BANCOS DE DADOS         | 2021.2   | CIC0097 | TA        | 35T45    |
            | ENGENHARIA DE SOFTWARE  | 2021.2   | CIC0105 | TA        | 35M12    |
            | PROGRAMAÇÃO CONCORRENTE | 2021.2   | CIC0202 | TA        | 35M34    |

    Scenario: Dispatch form for teachers of a class
        When I check "2021.2_CIC0097_TA"
        When I press "Enviar"
        Then I should be on the "Resultados" page
        And I expect to see the following templates:
            | template   | class                 | teacher   | role    | status  |
            | Template 2 | 2021.2 - CIC0097 - TA | Maristela | teacher | pending |

    Scenario: Coordinator forgets to select a class
        When I press "Enviar"
        Then I expect to see "Selecione uma turma"

    Scenario: There are no classes in the current semester
        Given I am on the "Envio" page
        Then I expect to see "Não há turmas disponíveis para envio"