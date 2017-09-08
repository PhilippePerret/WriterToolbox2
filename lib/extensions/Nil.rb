# encoding: UTF-8

class NilClass

  # Cf. la méthode String
  def as_id_list
    []
  end

  # Pour compatibilité quand une valeur est nil
  def in_hidden attrs
    "".in_hidden attrs
  end

  # Cf. la méthode String#set_bit
  def set_bit ibit, valbit
    ''.set_bit(ibit, valbit)
  end

  # Juste pour compatibilité avec les mêmes méthodes
  # pour String, Array, etc.
  def nil_if_empty
    nil
  end

  def nil_or_empty?
    true
  end

  def empty?
    true
  end

  def numeric?
    false
  end
end
