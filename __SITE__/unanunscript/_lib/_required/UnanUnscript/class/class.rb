# encoding: UTF-8
class Unan

  extend MainSectionMethods

  class << self

    # Tarif complet du programme
    def tarif ; 19.8 end

    # Le dossier général de cette section
    # TODO Il faudrait pouvoir la calculer automatiquement dans le
    # module `MainSectionMethods` pour que toutes les sections qui le
    # chargent puissent en profiter
    def folder
      @folder ||= File.join('.','__SITE__','unanunscript')
    end

  end #/ << self
end #/ UnanUnscript
