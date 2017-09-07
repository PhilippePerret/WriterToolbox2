=begin

  Support de test pour la collection Narration

=end

require './__SITE__/narration/_lib/_required/constants'

# Remplir le formulaire de data de page avec les données +d+ transmises.
# Si +submit+ est true, on soumet aussi le formulaire en cliquant le
# bon bouton.
def narration_fill_form_with d, submit = nil
  within('form#narration_edit_data_form') do
    d.each do |prop, dprop|
      dprop[:ftype] || next
      field_id = "page_#{prop}"
      case dprop[:ftype]
      when :cb
        dprop[:value] == true ? check(field_id) : uncheck(field_id)
      when :select
        select(dprop[:value], from: field_id)
      when :text
        fill_in( field_id, with: dprop[:value])
      end
    end
    shot('form-filled-for-create-page')
    submit && click_button(d[:id] ? 'Créer' : 'Enregistrer')
  end
end

# Retourne un tableau complet avec les données d'une page narration
# à créer
#
# @return {Hash} data
#                 Les données pour une page/chapitre/sous-chapitre
#                 Noter que les valeurs à mettre dans les champs sont
#                 spécifiées dans `:value` tandis que les valeurs réelles,
#                 à enregistrer, sont spécifiées dans `:real_value`.
#                 (:value contient le titre de l'item d'une liste, par
#                  exemple).
#                 Noter également qu'il faut utiliser chaque fois cette
#                 propriété :value pour obtenir la valeur. Donc on ne doit
#                 pas faire `data[:livre_id]` pour obtenir la valeur de
#                 l'identifiant du livre mais `data[:livre_id][:value]`
#
#                 Ce Hash peut être utilisé pour remplir le formulaire
#                 d'édition d'une page/sous-chapitre/chapitre. Toutes les
#                 valeurs à mettre dans le formulaire définissent :ftype qui
#                 correspond au type de champ (:text, :select, :cb, etc.)
#                 La propriété `:options`, par exemple, ne définit pas cette
#                 propriété et ne sera donc pas mise dans le formulaire.
#
# @param {Hash} params
#   :livre_id
#     Si livre_id est spécifié, il sera mis dans :real_value et :value
#     prendra la valeur du nom, pour pouvoir être recherché dans le
#     menu du livre.
#   :type
#     Peut être spécifié par 1, 2, 3, 5, 'page', 'chapitre', 'sous-chapitre',
#     ou 'texte type'.
#     De la même manière que :livre_id, le :type fourni (1, 2, 3 ou 5)
#     sera remplacé par le nom du menu  et la valeur sera mise dans real_value
#     Mais le type peut être fourni aussi par 'page', 'sous-chapitre',
#     'chapitre' ou 'texte type'
#   :options
#     La valeur est calculée en fonction des autres choix.
#
LISTE_TYPES = [nil,'page','sous-chapitre','chapitre',nil,'texte type']
def narration_data_page params
  # options = '131'

  options = String.new

  params[:type] ||= 1
  type_rvalue, type_value =
    case params[:type]
    when 1, 2, 3, 5
      type_value = LISTE_TYPES[params[:type]]
      [params[:type], type_value]
    when 'page', 'sous-chapitre', 'chapitre', 'texte type'
      type_rvalue = LISTE_TYPES.index(params[:type])
      [type_rvalue, params[:type]]
    end

  options << type_rvalue.to_s

  # Le livre
  data_livre =
    if params[:livre_id]
      Narration::LIVRES[params[:livre_id]]
    else
      nil
    end
  # Titre du livre
  titre_livre = data_livre ? data_livre[:hname] : ''

  # Niveau de développement
  params[:nivdev] ||= 1
  nivdev_value = Narration::NIVEAUX_DEVELOPPEMENT[params[:nivdev]][:hname]
  options << params[:nivdev].to_s(11)

  # Page seulement pour le web
  params.key?(:only_web) || params[:only_web] = false
  options << (params[:only_web] ? '1' : '0')

  # Priorité
  params[:priority] ||= 0
  value_priority = Narration::PRIORITIES[params[:priority]][:hname]
  options << params[:priority].to_s

  # Handler et fichier final
  md_file = dyn_file = nil
  if [1,5].include?(type_rvalue)
    params[:handler] ||= 'tests/page_test'
    if data_livre
      affixe_file = File.join('.','__SITE__','narration','_data',data_livre[:folder], params[:handler])
      md_file   = "#{affixe_file}.md"
      dyn_file  = "#{affixe_file}.dyn.erb"
    end
  else
    params[:handler]  ||= nil # pour la clarté
    params[:nivdev]   ||= 0
    params[:priority] ||= 0
  end

  datapage = {
    id:           {value: params[:id], ftype: :text},
    titre:        {value: params[:titre] || "Un titre à #{Time.now}", ftype: :text},
    type:         {value: type_value, real_value: type_rvalue,     ftype: :select},
    livre_id:     {value: titre_livre, real_value: params[:livre_id],  ftype: :select},
    handler:      {value: params[:handler], ftype: :text},
    description:  {value: params[:description] || "La description de la nouvelle page à #{Time.now}", ftype: :text},
    nivdev:       {value: nivdev_value, real_value: params[:nivdev], ftype: :select},
    priority:     {value: value_priority, real_value: params[:priority], ftype: :select},
    only_web:     {value: params[:only_web] || false, ftype: :cb},
    create_file:  {value: true, type: :cb},
    # Pour convénience
    created_at:   {value: Time.now.to_i,  ftype: nil},
    updated_at:   {value: Time.now.to_i,  ftype: nil},
    completed_at: {value: Time.now.to_i,  ftype: nil},
    options:      {value: options,        ftype: nil},
    md_file:      {value: md_file,        ftype: nil},
    dyn_file:     {value: dyn_file,       ftype: nil}
  }

  return datapage
end


# Crée un page narration dans la table
#
# ATTENTION : il vaut mieux penser à détruire cette page en fin
# de test en appelant la méthode :
# remove_page_narration_test(page_id)
# @return {Hash}  page_data
#                 L'intégralité des données enregistrées
def create_page_narration_test params = nil

  params ||= Hash.new

  # Avant d'opérer, on crée une fausse page pour pouvoir la détruire
  # ensuite. On la met avec un identifiant haut
  unless params.key?(:id)
    nid = 10000
    while site.db.count(:cnarration,'narration',{id:nid}) > 0
      nid += 1
    end
    params[:id] = nid
  end

  datapage = narration_data_page(params)

  data_fake_page = {
    id:             params[:id], # peut être nil
    titre:          datapage[:titre][:value],
    description:    datapage[:description][:value],
    options:        datapage[:options][:value],
    handler:        datapage[:handler][:value],
    livre_id:       datapage[:livre_id][:real_value],
    created_at:     datapage[:created_at][:value],
    updated_at:     datapage[:updated_at][:value],
    completed_at:   datapage[:completed_at][:value]
  }

  id_new = site.db.insert(:cnarration,'narration',data_fake_page)
  data_fake_page[:id] ||= id_new

  # === Vérifier que la page a bien été créée ===
  expect(site.db.count(:cnarration,'narration',{id:data_fake_page[:id]})).to eq 1

  return data_fake_page
end

# Détruire la page narration en question
#
# Noter qu'une sauvegarde de la collection peut être faite
# et que donc on peut tout simplement la recharger
# pour récupérer les données initiales.
# Cf. le support DB, méthode #backup_narration
def remove_page_narration_test page_id
  site.db.delete(:cnarration,'narration',{id: page_id})
  # === Vérifier que la page a été détruite ===
  expect(site.db.count(:cnarration,'narration',{id:page_id})).to eq 0
end


# Au chargement de ce fichier
