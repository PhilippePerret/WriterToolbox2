# encoding: utf-8
#
class MD2Page
  class << self

    attr_reader :src_path
    attr_reader :options


    # Dossier des images
    #
    def images_folder
      @images_folder ||= options[:img_folder]
    end



    # Chemin au fichier de destination
    def dest_path
      @dest_path ||= options[:dest] || "#{src_path}.dyn.erb"
    end


  end #/<< self
end #/MD2Page
