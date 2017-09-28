
# rejoindre le quiz d'ID +quiz_id+
def goto_quiz quiz_id
  visit "#{base_url}/quiz/21"
end

def quiz_set_usage_unique quiz_id
  q = Quiz.new(quiz_id)
  specs = q.data[:specs]
  bit14 = specs[14].to_i
  if bit14 & 1 > 0
    bit14 -= 1
    specs[14] = bit14.to_s
    q.set(specs: specs)
  end
end
def quiz_set_usage_multiple quiz_id
  q = Quiz.new(quiz_id)
  specs = q.data[:specs]
  bit14 = specs[14].to_i
  if bit14 & 1 == 0
    bit14 |= 1
    specs[14] = bit14.to_s
    q.set(specs: specs)
  end
end
