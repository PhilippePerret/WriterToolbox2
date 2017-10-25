=begin

  Cette feuille teste le suivi d'un sujet.
  Ce suivi peut se faire :
  1. depuis le fil de discussion, en cliquant simplement sur "Suivre le sujet"
  2. depuis une réponse (en cliquant la case 'Suivre ce sujet')

=end
require_lib_site
require_support_integration
require_support_forum
require_support_db_for_test
require_support_mails_for_test

feature "Suivi d'un sujet" do
  before(:all) do
    # En cas d'erreur, on peut relancer :
    # reset_all_data_forum
  end

  context 'avec un user ne suivant pas le sujet' do


    context 'non identifié au site' do
      scenario 'ne peut pas suivre le sujet' do
        hsujet = forum_get_sujet
        sujet_id = hsujet[:id]
        visit "#{base_url}/forum/sujet/#{sujet_id}"
        # sleep 30
        expect(page).to have_tag('section#contents') do
          with_tag('div.buttons.top') do
            with_tag('a', with:{href: "forum/sujet/#{sujet_id}?op=suivre&v=1"}, text: 'Suivre ce sujet')
          end
          with_tag('div.buttons.bottom') do
            with_tag('a', with:{href: "forum/sujet/#{sujet_id}?op=suivre&v=1"}, text: 'Suivre ce sujet')
          end
        end
        success 'les boutons (haut/bas) pour suivre le sujet existe'

        within('div.buttons.top'){click_link 'Suivre ce sujet'}
        # sleep 10
        expect(page).to have_tag('h2', text: 'Forum - suivi de sujet')
        expect(page).to have_content("Pour pouvoir suivre un sujet, vous devez être inscrit")
        expect(page).to have_tag('section#contents') do
          with_tag('a', with:{href: 'user/signup'})
        end
        success 'le visiteur non identifié trouve une page lui indiquant qu’il doit s’inscrire'

        expect(page).to have_tag('a', with:{href: "forum/sujet/#{sujet_id}?from=1"}, text: '→ Retourner au sujet')
        success 'la page contient aussi un lien pour retourner au sujet'

        within('section#contents'){click_link 'S’inscrire'}
        expect(page).to have_tag('h2', text: 'S’inscrire sur le site')
        expect(page).to have_tag('form', with: {id: 'signup_form'})
        success 'en cliquant sur le lien pour l’inscription, le visiteur rejoint le formulaire d’inscription'
      end
      #/scénario non identifié ne peut pas suivre le sujet
    end





    context 'identifié au site' do
      scenario 'il peut faire la demande de suivi d’un sujet' do
        hfollower = create_new_user
        hsujet = forum_get_sujet
        sujet_id = hsujet[:id]

        identify hfollower
        visit "#{base_url}/forum/sujet/#{sujet_id}"

        expect(page).to have_tag('section#contents') do
          with_tag('div.buttons.top') do
            with_tag('a', with:{href: "forum/sujet/#{sujet_id}?op=suivre&v=1"}, text: 'Suivre ce sujet')
          end
          with_tag('div.buttons.bottom') do
            with_tag('a', with:{href: "forum/sujet/#{sujet_id}?op=suivre&v=1"}, text: 'Suivre ce sujet')
          end
        end
        success 'les boutons (haut/bas) pour suivre le sujet existe'

        within('div.buttons.top'){click_link 'Suivre ce sujet'}
        # sleep 10
        expect(page).to have_tag('h2', text: 'Forum - suivi de sujet')
        expect(page).to have_content("Vous suivez à présent le sujet « #{hsujet[:titre]} »")
        nombre = site.db.count(:forum,'follows',{user_id: hfollower[:id], sujet_id: sujet_id})
        expect(nombre).to eq 1
        success 'le visiteur identifié s’inscrit avec succès au sujet'

        expect(page).to have_tag('a', with:{href: "forum/sujet/#{sujet_id}?from=1"}, text: '→ Retourner au sujet')
        expect(page).to have_content("Vous pouvez retrouver tous les sujets que vous suivez sur votre page de profil.")
        expect(page).to have_tag('section#contents')do
          with_tag('a', with:{href: "user/profil"}, text: 'votre page de profil')
        end
        success 'la page contient aussi un lien pour retourner au sujet et un lien pour voir tous les sujets suivis'
      end
    end
  end







  context 'avec un user suivant déjà un sujet (donc forcément inscrit)' do

    scenario 'le lecteur peut ne plus suivre ce sujet' do
      # ========= PRÉPARATION =================
      # Un nouveau visiteur doit suivre un sujet tiré au hasard
      hfollower = create_new_user
      hsujet = forum_get_sujet
      sujet_id = hsujet[:id]

      # Requête pour que le visiteur suive le sujet
      site.db.use_database(:forum)
      site.db.execute(
        "INSERT INTO follows (user_id, sujet_id, created_at) VALUES (?, ?, ?)",
        [hfollower[:id], sujet_id, Time.now.to_i - 2.mois]
      )

      # ==========> PRÉ-TEST <===========
      nombre = site.db.count(:forum,'follows',{user_id: hfollower[:id], sujet_id: sujet_id})
      nombre == 1 || (expect(nombre).to eq 1) # l'user devrait suivre le sujet

      # Le visiteur rejoint le sujet qu'il suit
      identify hfollower
      visit "#{base_url}/forum/sujet/#{sujet_id}"

      expect(page).to have_tag('section#contents') do
        with_tag('div.buttons.top') do
          with_tag('a', with:{href: "forum/sujet/#{sujet_id}?op=suivre&v=0"}, text: 'Ne plus suivre ce sujet')
        end
        with_tag('div.buttons.bottom') do
          with_tag('a', with:{href: "forum/sujet/#{sujet_id}?op=suivre&v=0"}, text: 'Ne plus suivre ce sujet')
        end
      end
      success 'La page présente le bon titre pour ne plus suivre le sujet'

      # =============> TEST <============
      within('div.buttons.top'){click_link 'Ne plus suivre ce sujet'}

      # =========== VÉRIFICATION ===========
      nombre = site.db.count(:forum,'follows',{user_id: hfollower[:id], sujet_id: sujet_id})
      expect(nombre).to eq 0
      success 'l’user ne suit plus le sujet'

      expect(page).to have_tag('a', with:{href: "forum/sujet/#{sujet_id}?from=1"}, text: '→ Retourner au sujet')
      expect(page).to have_content("Vous pouvez retrouver tous les sujets que vous suivez sur votre page de profil.")
      expect(page).to have_tag('section#contents')do
        with_tag('a', with:{href: "user/profil"}, text: 'votre page de profil')
      end
      success 'la page contient aussi un lien pour retourner au sujet et un lien pour voir tous les sujets suivis'

    end
    #/scenario le lecteur peut ne plus suivre le sujet

  end
end
