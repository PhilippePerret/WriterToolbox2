# encoding: utf-8
class Analyse
  class AFile

    attr_reader :id

    # @param {Fixnum} fid
    #                 ID du fichier (dans la DB)
    #
    # @param {User}   who
    #                 L'User courant, qui peut être n'importe qui.
    #                 S'il est défini, il permettra de définir la propriété
    #                 `ufiler` du fichier utile pour connaitre le statut 
    #                 de l'user et savoir ce qu'il peut faire.
    #
    def initialize fid, who = nil
      @id = fid
      if who != nil 
        @ufiler = UFiler.new(analyse, self, who)
        analyse.define_uanalyser(who)
      end
    end

    def analyse
      @analyse ||= Analyse.new(data[:film_id]) # NE PAS METTRE LE SECOND ARG ICI (cf. N0001)
    end

    # Rappel : le `fpath` d'un fichier, c'est le dossier qui contiendra toutes ses versions, 
    # en tout cas les dernières.
    def fpath
      @path ||= File.join('.','__SITE__','analyser','_data_','files',"#{data[:film_id]}", "#{id}")
    end

    # Extension du fichier en fonction de son type
    # (je pourrais le mettre dans un Array, mais je préfère bien le lire)

    def extension
      case data[:specs][1].to_i
      when 0 then 'md'
      when 1 then 'film' # collecte
      when 2 then 'persos'
      when 3 then 'brins'
      when 4 then 'stt'
      when 5 then 'evc'
      when 6 then 'prc'
      else 'md'
      end
    end

    # DATA du fichier (dans la table `files_analyses`)

    def data
      @data ||= site.db.select(:biblio,'files_analyses',{id: @id}).first
    end

  end #/AFile
end #/Analyse
