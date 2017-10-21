# encoding: utf-8
class Analyse

  # L'user dans l'analyse, qu'il soit simple lecteur ou administrateur
  # cf. le manuel.
  #
  # Permet de bénéficier des méthodes .creator? etc.
  #
  # Doit être défini par Analyse.uanalyser = Analyse::UAnalyser.new(analyse, user)
  # lors de l'"entrée" de l'user dans l'instance de l'analyse.
  #
  attr_accessor :uanalyser

  class UAnalyser

    attr_reader :analyse
    attr_reader :real_user

    # @param {Analyse}  analyse
    #                   L'instance de l'analyse dont il est question
    # @param {User}     ruser
    #                   Le "vrai" user visitant l'analyse
    #
    def initialize analyse, ruser
      analyse.is_a?(Analyse)  || raise("Le premier argument doit être une instance d'Analyse.")
      ruser.is_a?(User)       || raise('Le second argument doit être une instance d’User.')
      @analyse   = analyse
      @real_user = ruser
    end

    # TRUE si l'user est créateur de l'analyse
    def creator? ; state(:creator) end
    # TRUE si l'user est rédacteur de l'analyse
    def redactor? ; state(:redactor) end
    # TRUE si l'user est (aussi) corrector
    def corrector? ; state(:corrector) end
    # TRUE si l'user est seulement corrector
    def simple_corrector? ; state(:scorrector) end
    # TRUE si l'user est administrateur
    def admin? ; state(:admin) end
    # TRUE si l'user est actif en ce moment
    def actif? ; state(:actif) end

    def state key
      @states ||= Hash.new
      @states[key] ||=
        case key
        when :creator     then role & 32 > 0
        when :redactor    then role & (8|16|32) > 0
        when :corrector   then role & 4 > 0
        when :scorrector  then [4,5].include?(role)
        when :admin       then real_user.admin?
        when :actif       then role & 1 > 0
        end
    end

    def role
      @role ||= data.nil? ? 0 : data[:role]
    end

    # Données de l'user pour cette analyse.
    # Mais ces données peuvent ne pas exister du tout, puisqu'il s'agit
    # ici d'un user quelconque.
    def data
      @data ||= 
        site.db.select(
          :biblio,
          'user_per_analyse',
          {film_id: analyse.id, user_id: real_user.id}
      ).first
    end

  end #/UAnalyser

end#/Analyse
