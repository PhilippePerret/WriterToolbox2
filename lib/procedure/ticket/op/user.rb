# encoding: UTF-8
=begin

  Opération qui peuvent être employées dans les codes des tickets
  Par exemple, pour confirmer le mail, on met dans le code :
  User.get(<id user>).confirm_mail.

=end
class User

  def confirm_mail
    set(options: options.set_bit(2,1))
  end

end #/User
