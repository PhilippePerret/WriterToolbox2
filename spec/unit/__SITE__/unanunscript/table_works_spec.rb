=begin

  Test concernant la création de la table unan_works_<id auteur>

=end

require_lib_site
require_support_db_for_test
require_support_unanunscript

describe 'Unan::Work' do
  describe 'Tables `users_tables.unan_works_<id auteur>`' do
    before(:all) do
      # On charge le mininum de Unan
      require_folder './__SITE__/unanunscript/_lib/_required'
      # On charge le module dont on a besoin ici
      Unan.require_module 'update_table_works_auteur'
    end
    describe '#create_table_works' do
      it 'répond' do
        expect(Unan::Work).to respond_to :create_table_works
      end
      it 'produit une erreur si aucun argument' do
        expect{Unan::Work.create_table_works}.to raise_error ArgumentError
      end
      it 'produit une erreur si l’argument n’est pas un user' do
        [2, true, {un:'hash'}, ['une','liste'], nil].each do |bad|
          expect{Unan::Work.create_table_works(bad)}.to raise_error ArgumentError
        end
      end
      it 'construit la table si l’argument est bien un User' do
        udata = create_new_user

        # On s'assure d'abord que la table n'existe pas
        expect{site.db.count(:users_tables,"unan_works_#{udata[:id]}")}.to raise_error(Mysql2::Error)

        # ======> TEST <=========
        u = User.get(udata[:id], force = true)
        Unan::Work.create_table_works(u)

        # ======== VÉRIFICATION =========
        expect(site.db.count(:users_tables,"unan_works_#{udata[:id]}")).to eq 0

      end
    end
    describe '#ensure_table_works_exists' do
      it 'répond' do
        expect(Unan::Work).to respond_to :ensure_table_works_exists
      end
      it 'produit une erreur si l’argument n’existe pas ou n’est pas un User' do
        expect{Unan::Work.ensure_table_works_exists}.to raise_error ArgumentError
        [2, true, {un:'hash'}, ['une','liste'], nil].each do |bad|
          expect{Unan::Work.ensure_table_works_exists(bad)}.to raise_error ArgumentError
        end
      end
      it 'crée la table si elle n’existe pas' do
        sleep 1
        themessage = "Je crée la table le #{Time.now}"
        allow(Unan::Work).to receive(:create_table_works){ $message = "#{themessage}"}

        udata = create_new_user
        # On s'assure d'abord que la table n'existe pas
        expect{site.db.count(:users_tables,"unan_works_#{udata[:id]}")}.to raise_error(Mysql2::Error)

        # Si la table n'est pas créée, on passe par la création
        # ===========> TEST <=============
        u = User.get(udata[:id], force = true)
        Unan::Work.ensure_table_works_exists(u)

        # =========== VÉRIFICATION ==========
        expect($message).to eq themessage
      end
      it 'ne crée pas la table si elle existe' do
        sleep 1
        udata = create_new_user
        u = User.get(udata[:id], force = true)
        Unan::Work.create_table_works(u)
        # ======== PRÉ-VÉRIFICATION =========
        expect(site.db.count(:users_tables,"unan_works_#{udata[:id]}")).to eq 0

        themessage = "Je crée la table le #{Time.now}"
        allow(Unan::Work).to receive(:create_table_works){ $message = "#{themessage}"}

        # ========> TEST <===========
        Unan::Work.ensure_table_works_exists(u)

        # ============ VÉRIFICATION ============
        expect($message).not_to eq themessage
        # (ce qui prouve qu'on n'est pas passsé par la création)

      end
    end

    describe '#update_table_works_auteur' do
      it 'répond' do
        expect(Unan::Work).to respond_to :update_table_works_auteur
      end
      it 'produit une erreur avec aucun argument' do
        expect{Unan::Work.update_table_works_auteur}.to raise_error ArgumentError
      end
      it 'produit une erreur avec un seul argument' do
        expect{Unan::Work.update_table_works_auteur(phil)}.to raise_error ArgumentError
      end
      it 'produit une erreur avec un auteur qui n’a pas de programme' do
        expect{Unan::Work.update_table_works_auteur(phil, 2, 4)}.to raise_error ArgumentError, "Phil ne suit pas le programme UN AN UN SCRIPT."
      end

      it 'permet d’actualiser la table des travaux en fonction des pday transmis' do
        sleep 1
        # Ici, c'est un user du programme qu'il faut créer
        huser = unanunscript_create_auteur
        # =========== PRÉ-VÉRIFCATION =========
        expect{site.db.count(:users_tables,"unan_works_#{huser[:id]}")}.to raise_error(Mysql2::Error)

        # =========== VALEURS UTILES ===========
        auteur = User.get(huser[:id], force = true)
        program_id = huser[:program].id
        tblname = "unan_works_#{auteur.id}"

        # =========> TEST <==========
        Unan::Work.update_table_works_auteur(auteur, 5, 8)

        # ============== VÉRIFICATIONS ===========
        expect(site.db.count(:users_tables,tblname)).not_to eq 0
        success "La table existe maintenant, sans aucun travail"

        # On relève tous les pdays concernés (en fait, seulement leurs travaux)
        hworks = Hash.new
        where_clause = "id >= 5 AND id <= 8"
        site.db.select(:unan, 'absolute_pdays', where_clause, [:works, :id]).each do |hpday|
          hworks.merge!(hpday[:id] => hpday[:works].as_id_list)
        end
        # puts "hworks des pdays 5 à 8 = #{hworks.inspect}"

        hworks.each do |pday, abswork_ids|
          abswork_ids.count > 0 || next
          habsworks = Hash.new
          site.db.select(:unan,'absolute_works',"id IN (#{abswork_ids.join(', ')})")
          .each do |habsw|
            habsworks.merge!( habsw[:id] => habsw)
          end
          abswork_ids.each do |abswork_id|
            where = "program_id = #{program_id} AND abs_work_id = #{abswork_id} AND abs_pday = #{pday}"
            # Hash du work-absolu (pour le type du travail)
            habswork = habsworks[abswork_id]
            # Hash du work-relatif
            hwork = site.db.select(:users_tables,tblname,where).first
            expect(hwork).not_to eq nil
            expect(hwork[:options][0..1]).to eq habswork[:type_w].to_s
          end
        end
        success "les travaux des pday 5 à 8 ont été ajoutés, avec le typew du travail"


        # On relève tous les pdays non concernés (1 à 4)
        hworks = Hash.new
        where_clause = "id >= 1 AND id <= 4"
        site.db.select(:unan, 'absolute_pdays', where_clause, [:works, :id]).each do |hpday|
          hworks.merge!(hpday[:id] => hpday[:works].as_id_list)
        end
        # puts "hworks des pday 1 à 4 = #{hworks.inspect}"

        hworks.each do |pday, abswork_ids|
          abswork_ids.each do |abswork_id|
            where = "program_id = #{program_id} AND abs_work_id = #{abswork_id} AND abs_pday = #{pday}"
            expect(site.db.count(:users_tables,tblname,where)).to eq 0
          end
        end
        success "les travaux des pday 1 à 4 n'ont pas été ajoutés"

        expect(auteur.program.options[7..9]).to eq '008'
        success "les options du programme ont été modifiées (mises au pday 8)"
      end
    end
  end
end
