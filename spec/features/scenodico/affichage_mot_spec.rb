require_lib_site
require_folder './lib/utils/md_to_page'
require_support_integration
require_support_scenodico

feature "Affichage du mot" do

  scenario "=> un visiteur quelconque trouve l'affichage normal du mot" do

    # On prend un mot qui possède des relatifs
    hmot = scenodico_get_mot("synonymes != '' AND relatifs != '' AND contraires != '' AND categories != ''")

    # puts "hmot = #{hmot.inspect}"
    visit "#{base_url}/scenodico/mot/#{hmot[:id]}"

    expect(page).to have_tag('div', with:{id: "scenodico-mot-#{hmot[:id]}", class:'fiche'}) do
      with_tag('div.titre', text: hmot[:mot])
      success 'affiche le mot'

      # Malheureusement, alors qu'on voit parfaitement que la définition est
      # affichée, aucun moyen de la tester… Je me contente de voir si le
      # div main existe et si la longueur de son contenu est bonne
      formated_desc = MD2Page.transpile(nil,{code: hmot[:definition], dest:nil, no_leading_p: true})
      formated_desc = formated_desc.gsub!(/<.*?>/,'')
      formated_len = formated_desc.length
      with_tag('div', with: {class: 'main'})
      texte = page.find('div.main').text
      texte_len = texte.length
      expect(texte_len).to be > formated_len - 50
      success 'affiche la description formatée'

      # Relatifs
      # ---------
      hmot[:data_relatifs].each do |rid, rdata|
        with_tag('a', with:{href:"scenodico/mot/#{rid}"}, text: /#{rdata[:mot]}/i)
      end
      success 'affiche les relatifs avec leur lien'

      # Catégories
      # ----------
      hmot[:categories].split(' ').each do |cate_id|
        dcate = hmot[:categories_by_cate_id][cate_id]
        with_tag('a', with: {href: "scenodico/categorie/#{dcate[:id]}"}, text: /#{dcate[:hname]}/i)
      end
      success 'affiche les catégories avec leur lien'
    end

    expect(page).not_to have_tag('a', with: {href:"admin/scenodico/#{hmot[:id]}?op=edit_mot"}, text: "éditer")
    success "N'affiche pas le lien d'édition du mot"

    hmot = scenodico_get_mot('liens != ""')
    # puts "hmot: #{hmot.inspect}"
    visit "#{base_url}/scenodico/mot/#{hmot[:id]}"
    hmot[:liens].force_encoding('utf-8')
      .split("\n")
      .each do |link|
        href, titre = link.split('::')
        expect(page).to have_tag('div', with:{id: "scenodico-mot-#{hmot[:id]}"}) do
          with_tag('a', with: {href: href}, text: titre)
        end
      end
    success 'affiche les liens formatés'

  end

  scenario 'un administrateur voir un affichage élargi du mot' do

    hmot = scenodico_get_mot("synonymes != '' AND relatifs != '' AND contraires != '' AND categories != ''")

    identify phil
    visit "#{base_url}/scenodico/mot/#{hmot[:id]}"
    expect(page).to have_tag('a', with: {href:"admin/scenodico/#{hmot[:id]}?op=edit_mot"}, text: "éditer")
    success "affiche le lien d'édition du mot"

    click_link('éditer')
    
    expect(page).to have_tag('h2', "Édition Scénodico")

  end
end
