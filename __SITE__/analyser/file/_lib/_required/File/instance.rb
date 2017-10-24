# encoding: utf-8
class Analyse
  class AFile

    # Titre du fichier

    def titre ; @titre ||= data[:titre] end

    # ID du créateur du fichier

    def creator_id
      @creator_id ||= find_creator_id
    end


    def find_creator_id
      site.db.select(
        :biblio,'user_per_file_analyse',
        "file_id = #{id} AND role & 1 LIMIT 1",
        [:user_id]
      )[0][:user_id]
    end

  end #/AFile
end #/Analyse
