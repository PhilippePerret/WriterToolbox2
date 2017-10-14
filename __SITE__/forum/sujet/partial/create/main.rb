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

        # En cas d'erreur de données, on redirige vers le formulaire
        # de création du sujet.
        hsujet = data_valides?(hsujet) || redirect_to('forum/sujet/new')

        # Création du sujet

        new_sujet_id = site.db.insert(:forum,'sujets',data2save(hsujet))

        # Création du premier message

        require_lib('forum:create_post')
        pdata = {
          content:      hsujet[:first_post],
          is_new_sujet: true
        }
        new_post_id = Forum::Post.create(creator, new_sujet_id, pdata)

        # Si le sujet doit être validé, il faut envoyer un message à
        # l'administration pour le premier message
        # Sinon, on lui envoie un simple message d'information
        # Note : les deux méthodes suivantes sont définies dans la librairie
        # `create_post` du forum
        ipost = Forum::Post.new(new_post_id)
        if creator.grade < 7
          ipost.notify_admin_post_require_validation new_sujet = true
        else
          ipost.notify_admin_new_sujet(creator, new_sujet_id)
        end

        # Pour terminer, on doit régler la valeur du dernier post du sujet
        # en mettant son premier
        # 
        # Noter que ça ne pose pas de problème de validation puisque le sujet
        # doit de toute façon être validé pour apparaitre.
        # Noter également que c'est la validation du premier post qui
        # provoquera aussi la validation (ou non) du premier sujet.
        #
        site.db.update(:forum,'sujets',{last_post_id: new_post_id},{id: new_sujet_id})

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
          last_post_id: nil, # sera réglé plus tard
          count: 1, # Il y a toujours un premier message créé
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
        bon || raise("Votre grade ne vous permet que créer un sujet ou une question, désolé.")
        bon = type_s == 2 || grade >= 5
        bon || raise("Vous n'avez pas le grade suffisant pour créer autre chose qu'une question technique.")
        hsujet[:titre] != nil       || raise("Le titre du sujet ou la question sont absolument requis.")
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
