=begin

  Test des votes pour les messages

=end
feature 'Vote pour les messages' do

  scenario '=> Un simple visiteur ne peut pas voter (il ne trouve pas les boutons)' do

  end

  scenario '=> Un simple visiteur ne peut pas forcer le vote par l’URL' do
    visit home_page
    visit "#{base_url}/forum/post/#{post_id}?op=u"


  end

end
