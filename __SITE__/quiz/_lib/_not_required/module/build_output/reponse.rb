# encoding: utf-8
#
#
# Class Quiz::Question::Reponse pour les réponses
#
class Quiz
  class Question
    class Reponse

      DELIMITEUR_DATA = ':::'


      # {String} Donnée brut de la réponse
      attr_reader :raw_data

      # {Fixnum} Index de la réponse dans la question, pour la retrouver
      attr_reader :index
      # {String} Le libellé de la réponse, i.e. son texte
      attr_reader :libelle
      # {Fixnum} Nombre de points que rapporte ou enlève la réponse
      attr_reader :points
      # {String|Nil} La raison pour laquelle cette réponse est la meilleure
      attr_reader :raison

      # Instance {Quiz::Question} de la question de cette réponse
      attr_reader :question


      def initialize rawdata, index, question
        @raw_data = rawdata
        @index    = index
        @question = question
        parse
      end


      # Retourne le code HTML d'affichage de la réponse
      def output
        for_cb = question.specs[0] == 'c'
        "<li id=\"li-#{dom_id}\" class=\"#{li_class}\">"+
          "<input"+
          " id=\"#{dom_id}\"" +
          " name=\"quiz[#{for_cb ? dom_id : question.dom_id }]\"" +
          " type=\"#{for_cb ? 'checkbox' : 'radio'}\"" +
          " value=\"#{index}\"" +
          "#{checked_code_erb}" +
          " />" +
          "<label for=\"#{dom_id}\">#{libelle}</label>"+
          "</li>"
      end

      # Class du LI contenant la réponse, permettant de l'adapter au
      # résultat de l'user qui l'aurait rempli.
      def li_class
        question.quiz != nil || (return '')
        "<%=quiz.class_li_reponse(#{question.id},#{index})%>"
      end

      # Retourne le code ERB permettant de régler cette réponse si elle est
      # choisie et que c'est un réaffichabe d'un quiz déjà fait.
      def checked_code_erb
        question.quiz != nil || (return '')
        "<%=quiz.code_checked(#{question.id},#{index})%>"
      end

      def dom_id
        @dom_id ||= "#{question.dom_id}-r-#{index}"
      end

      # Parse la donnée brute, c'est-à-dire en tire les données
      #
      # Cette méhtode est appelée dès l'instanciation.
      def parse
        d = raw_data.force_encoding('utf-8').split(DELIMITEUR_DATA)
        @libelle = d[0]
        @points  = d[1].to_i          # peut être négatif
        @raison  = d[2].nil_if_empty  # seulement si bonne réponse
      end
    end #/Reponse
  end #/Question
end #/Quiz
