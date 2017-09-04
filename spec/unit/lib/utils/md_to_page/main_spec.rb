=begin

  Cf. l'explication du module `md_to_page` dans le manuel, dans
  « Vues/Markdown.md »

=end
require_lib_site
require_folder './lib/utils/md_to_page'


describe 'MD2Page' do
  def factory
    @factory ||= YAML.load(File.read(from_to_code_file))
  end
  def from_to_code_file
    @from_to_code_file ||= File.join(thisfolder,'from_to_code.yml')
  end
  def thisfolder
    @thisfolder ||= File.dirname(__FILE__)
  end
  def file_md
    @file_md ||= "./essai_md2page.md"
  end
  def file_dyn
    @file_dyn ||= "#{file_md}.dyn.erb"
  end
  def erase_files
    File.exist?(file_md) && File.unlink(file_md)
    File.exist?(file_dyn) && File.unlink(file_dyn)
  end

  def write_md contenu
    File.open(file_md,'wb'){|f| f.write contenu}
  end
  def read_dyn keep_return = false
    File.exist?(file_dyn) || (return nil)
    res = File.read(file_dyn).strip.gsub(/&lt;/,'<').gsub(/&gt;/,'>')
    keep_return || res.gsub!(/\n/, '')
    res
  end
  alias :read_erb :read_dyn
  def transpile src = nil, params = nil
    params ||= Hash.new
    params.key?(:dest) || params.merge!(dest: file_dyn)
    MD2Page.transpile(src||file_md, params)
  end


  def compare t, t2
    arr = Array.new
    arr2 = Array.new
    t.each_byte { |l| arr << l }
    t2.each_byte { |l| arr2 << l }

    arr.each_with_index do |l, i|
      puts "#{t[i]} = #{t2[i]}"
      if l != arr2[i]
        puts "Le #{i+1}e byte est différent : #{t[i]} contre #{t2[i]}"
        break
      end
    end
  end



  before(:all) do
    erase_files
  end

  after(:all) do
    erase_files
  end


  it 'existe' do
    expect(defined?(MD2Page)).to eq 'constant'
  end
  describe '::transpile' do
    it 'répond' do
      expect(MD2Page).to respond_to :transpile
    end
    it 'produit le fichier dynamique' do
      erase_files
      write_md("Un code très simple.")
      expect(File.exist?(file_dyn)).to eq false
      transpile(file_md, {dest: file_dyn})
      expect(File.exist?(file_dyn)).to eq true
    end
  end


  describe 'la transpilation' do

    it '=> transforme correctement tous les textes' do
      factory.each do |dsample|
        write_md(dsample[:from])

        dsample[:args] && dsample[:args] = JSON.parse(dsample[:args], symbolize_names: true)

        # ============> TEST <================
        transpile(nil,dsample[:args])

        theto   = dsample[:to].gsub(/\n/,'')
        theres  = read_dyn
        dsample[:nospace] && begin

          theto.gsub!(/>\W+</,'><')
          theres.gsub!(/>\W+</,'><')
        end
        if theres != theto
          compare(theres, theto)
        end
        expect(theres).to eq theto
        success dsample[:it]
      end
    end

  end
end
