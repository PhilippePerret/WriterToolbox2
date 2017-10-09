# encoding: utf-8
class Forum
  class Sujet

    def route
      @route ||= "forum/sujet/#{self.id}"
    end

  end #/Sujet
end #/Forum

def sujet
  @sujet ||= Forum::Sujet.new(site.route.objet_id)
end
