# encoding: utf-8

class Unan
  class << self

      # Traite l'opération peut-être demandée
      # Note : ne le fait que lorsque `param(:op)` est défini.
      # 
      # Lire la N0001
      #
      # Cette méthode est une des premières appelée quand on arrive sur le
      # bureau, quel que soit l'onglet choisi. Elle suit la méthode qui checke
      # pour voir si les listes de tâche de l'auteur sont à jour.
      #
      def traite_operation ope
        ope != nil || return
        case ope
          # Les méthodes ci-dessous sont définies dans le fichier :
          # ./__SITE__/unanunscript/_lib/_not_required/module/taches/work_class.rb
          # ('gf' pour l'ouvrir)
          #
          # L'URL doit aussi contenir :wid qui définit l'IDentifiant du
          # travail-relatif concerné.
        when 'start_work' 
          # => Démarrer un travail (en cliquant sur son bouton)
          self.require_module 'taches'
          Work.start(user, param(:wid))
        when 'done_work'  
          # => Finir un travail (en cliquant sur son bouton)
          self.require_module 'taches'
          Work.done(user, param(:wid))
        end
      end


  end #/<< self Unan

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
