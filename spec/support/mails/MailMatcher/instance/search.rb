# encoding: UTF-8
class MailMatcher

  # Erreur rencontrée au cours de la recherche, sur ce
  # mail
  attr_accessor :error

  # Liste d'erreurs trouvées
  attr_reader :errors

  # Méthode principale qui checke si le mail correspond
  # aux données envoyées par +hmatch+, les conditions pour
  # que le mail soit valide.
  #
  # RETURN true si le mail matche et false dans le cas
  # contraire.
  #
  # Renseignement également la données `MailMatcher.almost_founds` qui mémorise les
  # mails qui répondent positivement à certains critères, afin de fournir
  # un message plus intéressant.
  #
  def match? hmatch
    if verbose
      puts "\n*** Test du message de titre #{subject} envoyé à #{to} (mode verbose)"
      puts "Paramètres : #{hmatch.inspect}"
    end
    @errors = Array.new
    # puts "Vérification d'un mail adressé à #{to}"
    message_strict = hmatch.delete(:message_strict)
    # puts "message_strict = #{message_strict.inspect}" if verbose
    subject_strict = hmatch.delete(:subject_strict)
    # Pour atteindre la propriété et la valeur attendue
    # dans l'exception levée
    prop      = nil
    expected  = nil

    # Pour retenir les propriétés qui ne matchent pas
    bad_props = {
      props: Hash.new,
      count: 0
    }
    is_almost_found       = false
    has_bad_destinataire  = false

    # Boucle sur toutes les propriétés à checker
    hmatch.each do |pro, exp|
      prop      = pro
      expected  = exp


      # Dans cette nouvelle version, on boucle sur toutes les propriétés
      # même en cas d'échec pour pouvoir récupérer les messages qui
      # correspondent presque

      begin
        case prop
        when :subject
          subject_match?(expected, subject_strict) || raise
        when :message
          message_match?(expected, message_strict) || raise
        when :message_has_tag, :message_has_tags
          matches_message_with_tags( message, expected ) || raise
        when :created_after, :created_before, :sent_after, :sent_before
          date_match?(prop, expected) || raise
        when :from
          from_match?(expected)  || raise
        when :to
          to_match?(expected)    || raise
        end
      rescue Exception => e
        # On passe ici si la propriété courante ne matche pas. Ça exclue
        # le message, mais on poursuit quand même.
        if prop == :to
          # Si le message diffère par le destinataire, il ne peut pas
          # être considéré comme "presque bon". On le retire purement
          # et simplement.
          has_bad_destinataire = true
        else
          bad_props[:props].merge!(prop => expected)
          bad_props[:count] += 1
        end
      else
        # On passe ici quand la propriété courante matche. Le message, si
        # finalement il n'est pas retenu à cause d'autre propriété que
        # celle-ci, sera dans les messages qui matchent presque
        is_almost_found = true
        MailMatcher.add_almost_found(prop, self)
      end

    end #/ fin de boucle sur toutes les propriétés

    if bad_props[:count] == 0
      # Le message est bon à garder
      MailMatcher.sup_almost_found(self) # pour supprimer de "presque"
      return true # Pour indiquer que le message est valide
    elsif has_bad_destinataire
      # Si ça n'est pas le bon destinataire, on le retire, tout
      # simplement
      MailMatcher.sup_almost_found(self)
      return false # pour indiquer que le message n'est pas valide
    else
      # Le message n'est pas bon à garder, on liste ce qui ne va pas chez
      # lui.
      @error = []
      bad_props[:props].map do |prop, expected|
        prop_value =
          case prop
          when :subject then subject
          when :message then
            decin   = message.index('<body')
            decout  = message.index('</body>') + '</body>'.length
            message[decin..decout].gsub(/\n/, "\n\e[32m")
          when :created_after, :sent_after, :created_before, :sent_before then sended_at
          when :from    then from
          when :to      then to
          else "- valeur inconnue -"
          end
        @error << "\n    🚫 #{prop.inspect}\n\e[32m          + trouvé : #{prop_value}\n\e[31m          - attendu : #{expected}"
      end
      @error = @error.join('')

      if is_almost_found
        MailMatcher.almost_found_add_bad_props(self, @error)
      end

      verbose && puts(@error)
      return false
    end # /fin de si le message ne matche pas
  end

  # TRUE si le sujet correspond, FALSE sinon
  def subject_match? conditions, strict = false
    if strict
      subject == conditions
    else
      expect_string_to_be_in(subject, conditions)
    end
  end

  # TRUE si le message correspond, FALSE sinon
  def message_match? expected, strict = false
    res =
      if strict
        message_content === expected
      else
        expect_string_to_be_in(message_content, expected)
      end
    if verbose
      puts "Test du message : #{message_content.inspect}"
      puts "Valeur attendue : #{expected.inspect}"
      puts "Stricte ? #{strict.inspect}"
      puts "Résultat = #{res.inspect}"
    end
    return res
  end

  # TRUE si la date correspond, FALSE sinon
  def date_match? prop, expected
    if verbose
      puts "-------------"
      puts "Date d'envoi du mail : #{sended_at.inspect} (#{sended_at.as_human_date(true, true, ' ', 'à')})"
      puts "À comparer à : #{expected.inspect} (#{expected.as_human_date(true, true, ' ', 'à')})"
      puts "Comparaison : #{prop.inspect}"
    end
    res =
      case prop
      when :sent_after, :created_after
        sended_at > expected
      when :sent_before, :created_before
        sended_at < expected
      end
    if verbose
      puts "Résultat : #{res.inspect}"
      puts "-------------"
    end
    return res
  end

  # TRUE si l'expéditeur correspond, FALSE sinon
  def from_match? expected
    from == expected
  end

  # TRUE si le destinataire correspond, FALSE sinon
  def to_match? expected
    to == expected
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Méthode qui recherche +expected+ (Regexp, Array ou String) dans +str+
  # RETURN true si c'est OK ou false dans le cas contraire
  #
  # Pour qu'une recherche soit valide, il faut trouver tous les
  # segments fournis. Si un seul manque, la correspondance est
  # fausse.
  #
  def expect_string_to_be_in str, expected
    expected.instance_of?(Array) || expected = [expected]
    expected.each do |segment|


      # On transforme toujours le segment en expression régulière
      reg_segment =
        case segment
        when Regexp then segment.dup
        else /#{Regexp::escape segment}/i
        end

      if str.match(reg_segment)
        @errors << "Segment “#{segment.to_s}” trouvé."
      else
        # Le segment n'a pas été trouvé, on peut s'arrêter là
        @errors << "Segment “#{segment.to_s}” NON TROUVÉ."
        return false
      end
    end
    # Tous les segments ont été trouvés
    return true
  end

end #/MailMatcher
