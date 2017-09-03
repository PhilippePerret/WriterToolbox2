require_lib_site
require_support_integration

feature "Livre de la collection Narration" do

  # Retourne un Array contenant les données Hash des +nombre_pages+
  # pages (attention : pas forcément les premières)
  def hash_pages livre_id = nil, nombre_pages = nil
    livre_id ||= 1
    nombre_pages ||= 20
    # On vérifie dans le détail l'affichage des 20 premières pages
    page_ids = site.db.select(:cnarration,'tdms',{id:livre_id}).first[:tdm]
      .split(',').collect{|n|n.to_i}[0..20]

    site.db.select(:cnarration,'narration',"id in (#{page_ids.join(',')})")
      .collect{|row| row}
  end

  scenario "Un visiteur quelconque peut afficher la table des matières d'un livre" do

    visit narration_page
    expect(page).to have_tag('ul#livres') do
      with_tag('a', text: 'La Structure')
    end

    click_link 'La Structure'
    expect(page).to have_tag('h2', text:'La collection Narration')
    expect(page).to have_tag('h3', text:'La Structure')

    expect(page).not_to have_tag('a', with:{href:'admin/narration/1?op=edit_tdm'}, text: 'éditer')

    hash_pages(1).each do |hpage|
      page_id = hpage[:id]
      typ_page = hpage[:options][0].to_i
      niv_dev = hpage[:options][1].to_i(11)
      is_a_page   = typ_page == 1
      is_readable = !is_a_page || niv_dev >= 4
      img =
        if niv_dev < 4
          'none'
        elsif niv_dev < 8
          'orange'
        else
          'vert'
        end

      expect(page).to have_tag('ul.livre_tdm') do
        with_tag('li', with:{id: "page-#{page_id}", class: "niv#{typ_page}"}) do
          if is_readable
            with_tag('a', with: {href:"narration/page/#{page_id}"}, text: /#{Regexp.escape(hpage[:titre])}/) do
              if is_a_page
                with_tag('img', with:{src: "./img/pictos/rond-#{img}.png"})
              end
            end
          else
            with_tag('span', with: {class: 'unreadable'}, text: /#{Regexp.escape(hpage[:titre])}/) do
              with_tag('img', with:{src: "./img/pictos/rond-#{img}.png"})
            end
          end
        end
      end
    end

  end

  scenario 'Un administrateur peut affiche et éditer la table des matières d’un livre' do
    identify phil
    visit narration_page

    expect(page).to have_tag('ul#livres') do
      with_tag('a', text: 'La Structure')
    end

    click_link 'La Structure'
    expect(page).to have_tag('h2', text:'La collection Narration')
    expect(page).to have_tag('h3', text: /La Structure/) do
      expect(page).to have_tag('a', with:{href:'admin/narration/1?op=edit_tdm'}, text: 'éditer')
    end

  end
end
