require_support_integration
require_support_scenodico

feature "Édition d'un mot du scénodico" do
  scenario "Un visiteur quelconque ne peut pas éditer un mot du scénodico" do
    visit "#{base_url}/admin/scenodico"
    expect(page).not_to have_tag('h2', text: "Édition Scénodico")
    visit "#{base_url}/admin/scenodico?op=edit_mot"
    expect(page).not_to have_tag('h2', text: "Édition Scénodico")
    visit "#{base_url}/admin/scenodico/2?op=edit_mot"
    expect(page).not_to have_tag('h2', text: "Édition Scénodico")
  end

  scenario 'un administrateur peut éditer un mot du scénodico' do
    hmot = scenodico_get_mot('relatifs != "" AND contraires != ""')
    puts "hmot = #{hmot.inspect}"
    identify phil
    visit "#{base_url}/admin/scenodico/2?op=edit_mot"
    expect(page).to have_tag('h2', text: "Édition Scénodico")
    expect(page).to have_tag('form', with: {id: "edit_mot_form"}) do
      with_tag('input', with:{type: 'text', id:'mot_mot', name:'mot[mot]'}, value: hmot[:mot])
      with_tag('textarea', with:{id: 'mot_definition', name: 'mot[definition]'})
      with_tag('input', with:{type: 'text', id:'mot_categories', name:'mot[categories]', value:hmot[:categories]})
      with_tag('input', with:{type: 'hidden', id:'mot_relatifs', name:'mot[relatifs]', value:hmot[:relatifs]})
      with_tag('input', with:{type: 'hidden', id:'mot_synonymes', name:'mot[synonymes]', value:hmot[:synonymes]})
      with_tag('input', with:{type: 'hidden', id:'mot_contraires', name:'mot[contraires]', value:hmot[:contraires]})
      with_tag('textarea', with: {id: 'mot_liens', name: 'mot[liens]'}, text: hmot[:liens])
      with_tag('input', with: {type:'submit', value:'Enregistrer'})
    end
    success "la page contient un formulaire valide"
  end
end
