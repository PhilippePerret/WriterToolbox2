# encoding: utf-8
class Analyse
  class << self

    def eject_user mess = nil
      mess ||= "Vous n’êtes pas en mesure d’accomplir cette opération…"
      redirect_to('home', [mess, :error])
      
    end
    def traite_operation he, ope
      he.analyste? || eject_user
      case ope
      when 'add_file'
        has_contributor?(analyse.id, he.id) || eject_user
        analyse.add_file
      end
    end

  end #/<< self



end #/Analyse
