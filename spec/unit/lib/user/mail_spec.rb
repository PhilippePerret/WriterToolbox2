
require_lib_site
require_support_mails_for_test

describe 'User Mailing' do
  describe '#send_mail' do
    it 'répond' do
      expect(user).to respond_to :send_mail
    end
    it 'ne permet pas d’envoyer un mail à l’user s’il n’est pas identifié' do
      User.current = User.new
      expect{user.send_mail({})}.to raise_error("User non identifié. Impossible d’envoyer un mail.")
    end
    it 'permet d’envoyer un mail à l’user s’il est identifié' do
      start_time = Time.now.to_i - 2
      folder_tmp_mails = './xtmp/mails'
      File.exist?(folder_tmp_mails) && FileUtils.rm_rf(folder_tmp_mails)
      User.current = User.get(1)
      data_mail = {
        subject:  "Le test du mail",
        message:  "<p>Le message d'essai</p>",
        formated: true,
        force_offline: false
      }
      expect{user.send_mail(data_mail)}.not_to raise_error

      expect(user).to have_mail(
        subject: "Le test du mail",
        message: "<p>Le message d'essai</p>",
        sent_after: start_time
      )

      expect(File.exist?(folder_tmp_mails)).to be true
      expect(Dir["#{folder_tmp_mails}/*.msh"].count).to eq 1
      success '  un fichier marshal a été produit pour le mail'
    end
  end

  context 'avec la propriété `short_subject`' do
    it 'utilise la version courte du préfixe sujet' do
      remove_mails
      start_time = Time.now.to_i - 1
      # =========> TEST <==========
      phil.send_mail(
        short_subject: "Préfix court",
        message: "<p>Un message</p>",
      )
      # ======== VÉRIFICATIONS ============
      expect(phil).to have_mail(
        subject: "[BOA] Préfix court",
        sent_after: start_time
      )
    end
  end
  context 'avec la donnée `no_header` à true' do
    it 'ne met pas d’entête au message' do
      start_time = Time.now.to_i - 1
      # ===========> TEST <==========
      phil.send_mail(
        subject:    "Un message sans header",
        message:    "<p>Le message</p>",
        no_header:  true
      )
      # ========== VÉRIFICATIONS ============
      expect(phil).to have_mails(sent_after: start_time)

      mail = get_mails_found.first
      # puts "Message : #{mail[:message]}"
      expect(mail[:message]).not_to have_tag('div#header')
    end
  end
  context 'avec la donnée `admin_header` à true' do
    it 'utilise l’entête pour l’administration (pas de citation)' do
      start_time = Time.now.to_i - 1
      # ===========> TEST <==========
      phil.send_mail(
        subject:        "Un message sans header",
        message:        "<p>Le message</p>",
        admin_header:   true
      )
      # ========== VÉRIFICATIONS ============
      expect(phil).to have_mails(sent_after: start_time)

      mail = get_mails_found.first
      # puts "Message : #{mail[:message]}"
      expect(mail[:message]).not_to have_tag('div#citation')
    end
  end
  context 'sans définir la donnée `:from`' do
    it 'la met à la valeur du mail du site' do
      start_time = Time.now.to_i - 1
      # ===========> TEST <==========
      marion.send_mail(
        subject:        "Un message sans header",
        message:        "<p>Le message</p>",
        admin_header:   true
      )
      # ========== VÉRIFICATIONS ============
      expect(phil).not_to have_mail(sent_after: start_time)
      expect(marion).to have_mails(sent_after: start_time)

      mail = get_mails_found.first
      # puts "Message : #{mail[:message]}"
      expect(mail[:to]).to eq marion.mail
      expect(mail[:from]).to eq site.configuration.main_mail
    end
  end
end
