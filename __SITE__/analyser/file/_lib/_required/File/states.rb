# encoding: utf-8
class Analyse
  class AFile

    # TRUE si l'user +who+ est le créateur du fichier
    # (attention, "créateur du fichier" ne signifie pas "créateur de
    # l'analyse")

    def creator? who
      role_of(who) & 1 > 0 
    end

    # TRUE si l'user +who+ peut rédiger ce fichier, c'est-à-dire s'il est
    # créateur de l'analyse, administrateur, rédacteur ou rédacteur occassionel
    
    def redactor? who
      analyse.creator?(who) || who.admin? || (role_of(who) & (1|2) > 0)
    end
    
    # TRUE si l'user +who+ est correcteur du fichier courant
    #
    # Noter qu'il peut être correcteur ou autre chose.
    
    def corrector? who
      role_of(who) & 4 > 0 
    end

    # TRUE si le fichier peut être lu (et seulement lu dans la partie
    # analyse) par n'importe quel inscrit.
    # C'est le 4e bit des specs du fichier
    
    def visible_par_inscrit?
      @is_visible_par_inscrit.nil? && @is_visible_par_inscrit = data[:specs][3] == '1'
      @is_visible_par_inscrit
    end


    # Rôle de +who+ pour ce fichier. Peut être NIL s'il ne partage rien
    # avec ce fichier ou 1 s'il est le créateur, 2 s'il est un rédacteur ou
    # 4 s'il le corrige aussi. C'est un bitwise.
    
    def role_of who
      @roles_of ||= Hash.new
      @roles_of[who.id] ||=
        begin
          rof = site.db.select(
            :biblio,'user_per_file_analyse',
            {user_id: who.id, file_id: self.id},
            [:role]
          ).first
          rof.nil? ? 0 : rof[:role]
        end
      @roles_of[who.id]
    end

  end #/AFile
end #/Analyse
