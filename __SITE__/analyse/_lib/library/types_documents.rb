# encoding: utf-8
#
# Pour les documents de l'analyse
#
# Pour charger cette librairie :          require_lib('analyse:types_documents')
#
# Cette librairie offre quelques constantes et quelques méthodes pour gérer
# les types de document d'une analyse.
# Elle n'est à charger qu'au besoin, lorsqu'on affiche par exemple le tableau
# de bord d'une analyse, pour voir le type de documents qu'elle possède.
#
class Analyse

  # DOCUMENTS D'UNE ANALYSE
  #
  # Constantes pour les bits 
  
  BDOC_COLLECT    = 1
  BDOC_COLPERSOS  = 2
  BDOC_COLBRINS   = 4
  # 8
  # 16
  BDOC_TDM        = 32
  BDOC_INTRO      = 64
  BDOC_COMMENTS   = 128
  BDOC_LECON      = 256
  BDOC_TIMELINE   = 512
  # 1024
  # 2048
  BDOC_DOCSPERSOS = 4096
  BDOC_DOCSSTT    = 8192
  BDOC_DOCSDYNA   = 16384
  BDOC_DOCSPROCS  = 32768
  BDOC_EVENTS     = 65536
  BDOC_NOTES      = 131072
  # 262144
  BDOC_STATS      = 524288
  # 1048576
  # 2097152
  # 4194304

  TYPES_DOCUMENTS = {
    BDOC_COLLECT    => {
      bit: BDOC_COLLECT,    hname: 'fichier de collecte', short_name: 'fichier collecte'},
    BDOC_COLPERSOS  => {
      bit: BDOC_COLPERSOS,  hname: 'fichier de personnages (collecte)', short_name: 'collecte persos'},
    BDOC_COLBRINS   => {
      bit: BDOC_COLBRINS,   hname: 'fichier de brins (collecte)', short_name: 'collecte brins'},
    BDOC_TDM        => {
      bit: BDOC_TDM,        hname: 'table des matières', short_name: 'TdM'},
    BDOC_INTRO      => {
      bit: BDOC_INTRO,      hname: 'Introduction conséquente', short_name: 'Intro'},
    BDOC_COMMENTS   => {
      bit: BDOC_COMMENTS,   hname: 'Documents commentaires étoffés', short_name: 'Comments'},
    BDOC_LECON      => {
      bit: BDOC_LECON,      hname: 'Leçon tirée du film', short_name: 'Leçon film'},
    BDOC_TIMELINE   => {
      bit: BDOC_TIMELINE,   hname: 'Timeline dynamique', short_name: 'Timeline'},
    BDOC_DOCSPERSOS => {
      bit: BDOC_DOCSPERSOS, hname: 'Documents sur les personnages', short_name: 'docs persos'},
    BDOC_DOCSSTT    => {
      bit: BDOC_DOCSSTT,    hname: 'Documents sur la structure', short_name: 'docs structure'},
    BDOC_DOCSDYNA   => {
      bit: BDOC_DOCSDYNA,   hname: 'Documents sur la dynamique', short_name: 'docs dyna.'},
    BDOC_DOCSPROCS  => {
      bit: BDOC_DOCSPROCS,  hname: 'Documents sur les procédés', short_name: 'docs procédés'},
    BDOC_EVENTS     => {
      bit: BDOC_EVENTS,     hname: 'Évènemenciers', short_name: 'events'},
    BDOC_NOTES      => {
      bit: BDOC_NOTES,      hname: 'Documents de notes', short_name: 'docs notes'},
    BDOC_STATS      => {
      bit: BDOC_STATS,      hname: 'Documents de statistiques', short_name: 'docs stats'}
  }

  DOCS_TYPES_TO_BIT = {
    collecte:         BDOC_COLLECT,
    collecte_persos:  BDOC_COLPERSOS,
    collecte_brins:   BDOC_COLBRINS,
    introduction:     BDOC_INTRO,
    commentaires:     BDOC_COMMENTS,
    lecon:            BDOC_LECON,
    timeline:         BDOC_TIMELINE,
    personnages:      BDOC_DOCSPERSOS,
    persos:           BDOC_DOCSPERSOS,
    structure:        BDOC_DOCSSTT,
    stt:              BDOC_DOCSSTT,
    dynamique:        BDOC_DOCSDYNA,
    procedes:         BDOC_DOCSPROCS,
    evenemenciers:    BDOC_EVENTS,
    events:           BDOC_EVENTS,
    notes:            BDOC_NOTES,
    statistiques:     BDOC_STATS,
    stats:            BDOC_STATS
  }

  # TRUE si l'analyse contient le document de type +type+
  #
  # @param {Fixnum|Symbol} type
  #         Soit la valeur du bit (clé dans DOCUMENTS_TYPES)
  #         Soit la clé dans la table de correspondance DOCS_TYPES_TO_BIT
  #
  def has_doc?(type)
    bit_type = type.is_a?(Fixnum) ? type : DOCS_TYPES_TO_BIT[type]
    bit_type != nil || raise("Le type doit être un Fixnum ou un Symbol.")
    return bits_documents.bitin(bit_type)
  end

  def bits_documents
    @bits_documents ||= (data[:specs][11..15] || '').ljust(5,'0').to_i(36)
  end

end #/Analyse
