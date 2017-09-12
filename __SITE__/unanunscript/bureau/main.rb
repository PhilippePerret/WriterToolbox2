# encoding: utf-8

class Unan

  # Les données de toutes les sections, pour un travail plus facile de construction
  # des pages du bureau.
  DATA_SECTIONS = {

    # Tout ce qui concerne le programme lui-même
    program: {hname: "Programme"},

    # Tout ce qui concerne le projet de l'auteur
    projet:  {hname: "Projet"},

    # Tout ce qui concerne les taches à exécuter
    taches: {hname: "Tâches"},

    # Tout ce qui concerne les pages de cours à lire
    cours:  {hname: "Pages"},

    # Tout ce qui concerne les quiz
    quiz:   {hname: "Quiz"},

    # Tout ce qui concerne le forum attaché au programme
    forum:  {hname: "Forum"},

    # Tout pour les préférences du programme, par exemple le rythme
    prefs:  {hname: "Préférences"},

    # Tout pour l'aide sur le programme
    aide:   {hname: "Aide"}

  }

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
    @program_id ||= begin
                      var['unan_program_id']
                    end
  end
end #/User

def section
  @section ||= Unan::Section.new(site.route.objet_id || 'program')
end
def program
  @program ||= Unan::UUProgram.new(user.program_id)
end
