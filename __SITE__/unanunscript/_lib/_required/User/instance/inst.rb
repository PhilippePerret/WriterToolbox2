# encoding: UTF-8
=begin

  Méthodes exclusivement réservées au program UAUS

=end
class User

  def program
    @program ||= Unan::UUProgram.new(program_id)
  end
  def program_id
    @program_id ||= var['unan_program_id']
  end

  def projet_id
    @projet_id ||= program.projet_id
  end

end #/User
