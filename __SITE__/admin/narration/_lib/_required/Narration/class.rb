# encoding: utf-8
class Narration
  class << self

    def main_titre options = nil
      site.titre_page(
        simple_link('admin/narration', 'Administration de Narration'),
        {
          under_buttons: [
            simple_link('narration', 'Narration (lecture)'),
            simple_link('admin/narration?op=edit_data', 'Pages (data)'),
            simple_link('admin/narration?op=edit_text', 'Pages (text)')
          ],
          subtitle: (options && options[:subtitle])
        }
      )
    end

  end #/<< self
end #/Narration
