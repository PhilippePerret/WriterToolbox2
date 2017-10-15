# encoding: utf-8
class Analyse
  class Film

    attr_reader :id

    def initialize film_id
      @id = film_id
    end

    def titre
      @titre ||= data[:titre].force_encoding('utf-8')
    end
    
    def data
      @data ||=
        begin
          request = <<-SQL
          SELECT f.*, fa.*,
            fa.realisateur AS director
            FROM films_analyses fa
            INNER JOIN filmodico f ON fa.id = f.id
            WHERE fa.id = #{self.id}
          SQL
          site.db.use_database(:biblio)
          site.db.execute(request).first
        end
    end
  end #/Film
end #/Analyse

