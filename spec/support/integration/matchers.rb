require 'rspec/expectations'

RSpec::Matchers.define :be_home_page do |expected|
  match do
    page.has_selector?('fieldset#last_updates') && page.has_selector?('section#incipit')
  end
  failure_message do
    "On devrait se trouver sur la page d'accueil"
  end
end
