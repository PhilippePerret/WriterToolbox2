require 'rspec/expectations'

RSpec::Matchers.define :be_home_page do |expected|
  match do
    page.has_selector?('fieldset#last_updates') && page.has_selector?('section#incipit')
  end
  failure_message do
    "On devrait se trouver sur la page d'accueil"
  end
  failure_message_when_negated do
    "On ne devrait pas se trouver sur la page d'accueil"
  end
end



RSpec::Matchers.define :be_signin_page do |expected|
  match do
    page.has_selector?('form#signin_form') && page.has_selector?('input[type="submit"][value="OK"]')
  end
  failure_message do
    "On devrait se trouver sur la page d'identification"
  end
  failure_message_when_negated do
    "On ne devrait pas se trouver sur la page d'identification"
  end
end
