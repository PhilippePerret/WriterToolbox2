# encoding: utf-8
class Analyse
  class AFile

    attr_reader :id

    def initialize fid
      @id = fid
    end


    def analyse
      @analyse ||= Analyse.new(data[:film_id])
    end

    def path
      @path ||= File.join('.','__SITE__','analyser','_data_','files',"#{data[:film_id]}", "#{id}.#{extension}")
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
