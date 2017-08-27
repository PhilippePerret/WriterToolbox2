# encoding: UTF-8
=begin

   Gestion des actualités du site

=end
class Updates


  extend  PropsAndDbMethods
  include PropsAndDbMethods

  TYPES = {
    'site'      => {hname: 'La Boite à Outils'},
    'narration' => {hname: 'Collection Narration'},
    'analyse'   => {hname: 'Analyse de film'},
    'unan'      => {hname: 'Programme UNAN'},
    'video'     => {hname: 'Tutoriel-vidéo'},
    'forum'     => {hname: 'Forum'},
    'filmodico' => {hname: 'Filmodico'},
    'scenodico' => {hname: 'Scénodico'}
  }

  # --------------------------------------------------------------------------------
  #
  #     CLASSE
  #
  # --------------------------------------------------------------------------------

  class << self


    # Renvoie la liste des actualisations en fonction des paramètres
    # choisis.
    # @param {Hash} params
    #               params[:filtre] Clé du filtre
    #                   :all (toutes), :home (page d'accueil), :mail (pour les mails)
    #               params[:group_by] Groupe par cette propriété (par exemple le type)
    def list params = nil
      params ||= Hash.new

      wclause = Array.new

      # Si le filtre est sur :home, il ne faut pas afficher les actualités
      # de plus d'un an.
      params[:created_after] && begin
        wclause << "created_at > #{params[:created_after]}"
      end

      # Si le filtre est sur :home (ou ???), il ne faut qu'afficher les
      # updates à afficher (1er bit pas à zéro)
      (params[:displayable] || params[:not_sent]) && begin
        wclause << "SUBSTRING(options,1,1) != '0'"
      end

      params[:not_sent] && begin
        wclause << "SUBSTRING(options,2,1) != '1'"
      end

      # On stringifie la clause where pour pouvoir ajouter des
      # choses au bout.
      wclause = wclause.join(' AND ')

      params[:limit] && begin
        wclause << " LIMIT #{params[:limit]}"
      end

      if params[:group_by_type]
        resultat = Hash.new
      else
        resultat = Array.new
      end

      wclause = wclause.nil_if_empty

      site.db.select(:cold,'updates', wclause).each do |hd|
        instance = new(hd)
        if params[:group_by_type]
          gtype = hd[:type]
          resultat.key?(gtype) || resultat.merge!(gtype => {type: gtype, updates: Array.new})
          resultat[gtype][:updates] << instance
        else
          resultat << instance
        end
      end

      return resultat
    end
    # Ajoute une actualité dans la base
    #
    # @param {Hash} hdata
    #               Les données de l'actualité
    def add hdata
      data_valides?(hdata) || return
      insert(hdata)
    end

    # Return TRUE si les données sont valides, FALSE dans le
    # cas contraire.
    def data_valides? hdata
      hdata || raise("Il faut fournir les données à valider.")
      hdata[:message] = hdata[:message].nil_if_empty
      hdata[:message] || raise("Il faut impérativement définir le message de l'actualisation.")
      hdata[:type] && TYPES.key?(hdata[:type]) || raise("Le type #{hdata[:type]} est inconnu de nos services…")

      return true
    rescue Exception => e
      __error e.message
      return false
    end
    def base_n_table
      @base_n_table ||= [:cold, 'updates']
    end
  end #/<< self

  # --------------------------------------------------------------------------------
  #
  #    INSTANCE
  #
  # --------------------------------------------------------------------------------
  attr_reader :id, :message, :route, :created_at
  def initialize hdata = nil
    hdata && dispatch(hdata)
  end

  def as_li
    c = "<li id=\"update-#{id}\" class=\"update\">"
    c << "<span class=\"date\">#{Time.at(created_at).strftime('%d %m %Y')}</span>"
    c << "<span>#{message}</span>"
    route && begin
      c << "<a href=\"#{route}\" class=\"update\">🔍</a>"
    end
    c << '</li>'
    return c
  end

  def base_n_table ; self.class.base_n_table end

end #/Updates
