# encoding: utf-8

class Unan

  class UUProgram
    class << self

      # Vérifie que la table des works-relatifs de l'auteur est à jour, 
      # et l'actualise et la crée si c'est nécessaire.
      # Rappel : pour savoir si la table est à jour, on regarde les bits
      # 8 à 10 de program.option, qui contiennent le jour-programme de la
      # dernière actualisation (ou rien du tout). Si cette valeur correspond
      # au jour-programme courant du programme de l'auteur, alors rien n'est
      # à faire, sinon, il faut charger le module d'actualisation et demander
      # l'actualisation/création de la table.
      def check_if_table_works_auteur_uptodate program
        program.current_pday == program.options[7..9].to_i(10) && return
        Unan.require_module 'update_table_works_auteur'
        from_pday = (program.options[7..9] || '1').to_i(10)
        Unan::Work.update_table_works_auteur(program.auteur, from_pday, program.current_pday)
      end

    end #/<< self UUProgram
  end #/ UUProgram

  class Section


    # ID de la section
    # Note : ce n'est pas un nombre mais un string, clé de DATA_SECTIONS
    #
    attr_reader :id

    def initialize section_id
      @id = section_id.to_sym
    end

    def htitre
      @htitre ||= '<h3 id="section_titre">'+data[:hname]+'</h3>'
    end

    def partiel
      @partiel ||= begin
                     thisfolder = File.dirname(__FILE__)
                     folder_partiels = File.join(thisfolder,'partial')
                     folder_partiel  = File.join(folder_partiels,self.id.to_s)
                     main_file = File.join(folder_partiel,'main.erb')
                     site.load_folder(folder_partiel)
                     deserb(main_file)
                   end
    end

    def bind ; binding() end

    def data
      @data ||= DATA_SECTIONS[id]
    end
  end #/Section
end #/Unan
class User
  def program_id
    @program_id ||= var['unan_program_id']
  end
end #/User

def section
  @section ||= Unan::Section.new(site.route.objet_id || 'program')
end
def program
  @program ||= Unan::UUProgram.new(user.program_id)
end
