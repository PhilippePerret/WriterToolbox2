# encoding: utf-8

if user.grade < 1
  raise NotAccessibleViewError.new('Vous n’êtes pas autorisé à créer un sujet ou une question technique.')
end

class Forum
  class Sujet
    class << self

      # Méthode créant le sujet avec les paramètres +hsujet+
      #
      # @param {Hash} hsujet
      #               Doit contenir:
      #                 :titre      Le titre du sujet/question
      #                 :type_s     Le type S
      #
      # @param {Fixnum|User} creator_id
      #               Le créateur du sujet (en général le user courant)
      #               On peut envoyer aussi son identifiant seulement
      #
      # @return {Fixnum} ID du nouveau sujet
      # @produit L'enregistrement du nouveau sujet
      #          Envoie un mail pour demander sa validation si nécessaire
      #          L'ajouter au sujet à annoncer (par ses specs)
      def create hsujet, creator
        creator.is_a?(Fixnum) && creator = User.get(creator)

        hsujet.merge!(creator_id: creator.id, creator: creator)
        
        hsujet = data_valides?(hsujet) || begin
          redirect_to 'forum/post/new'
        end

        new_sujet_id = site.db.insert(:forum,'sujets',data2save(hsujet))

        return new_sujet_id
      end

      # retourne les données à sauver à partir des données +hsujet+
      def data2save hsujet
        specs = String.new
        bit_validate = (hsujet[:creator].grade < 7) ? '0' : '1' # validation
        specs << bit_validate 
        specs << hsujet[:type_s].to_s
        specs << '00' # le sujet précis, affecté plus tard
        specs << bit_validate # pour l'annonce, c'est comme la validation
                              # le sujet peut être annoncé seulement s'il est validé
        specs = specs.ljust(8,'0')
        {
          titre: hsujet[:titre],
          creator_id: hsujet[:creator_id],
          specs: specs,
          last_post_id: nil,
          count: 0,
          views: 0
        }
      end

      # Retourne true si les données +hsujet+ sont valides pour
      # créer un sujet, ou raise une erreur
      def data_valides? hsujet
        # On s'assure de la présence des données minimales
        hsujet[:creator_id] != nil  || raise("Ce sujet doit avoir un créateur.")
        hsujet[:type_s] != nil      || raise("Le type S du sujet devrait être défini.")
        # On s'assure pour commencer que le créateur du sujet
        # a le grade suffisant (en fonction du type S)
        type_s = hsujet[:type_s].to_i
        grade  = hsujet[:creator].grade
        bon = grade > 0
        bon || raise("Votre grade ne vous permet que de lire les messages publics, désolé.")
        bon = type_s > 1 && grade >= 5
        bon || raise("Vous n'avez pas le grade suffisant pour créer autre chose qu'une question.")
        hsujet[:titre] != nil       || raise("Le titre du sujet est absolument requis.")
        return hsujet
      rescue Exception => e
        debug e
        __error e.message
        return false
      end
      
      # Retourne le hash des données du sujet récupéré dans les
      # paramètres
      #
      # Note : normalement, param(:sujet) est toujours défini lorsqu'on arrive
      # ici, mais si un petit malin appelle l'adresse directement, ce paramètre
      # n'existera pas.
      def get_in_params
        h = Hash.new
        (param(:sujet) || Hash.new).each do |k, v|
          h.merge!(k => v.nil_if_empty)
        end
        h
      end


    end #/<< self Sujet
  end #/Sujet
end #/Forum
