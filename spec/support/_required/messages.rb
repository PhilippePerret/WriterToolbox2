=begin

  Pour définir le mode verbose/quiet :

      mode_verbose true/false

=end

# Pour écrire un message de succès en console
def success message
  verbose? || return
  puts "\e[32m#{success_tab}#{message}\e[0m"
  sleep 0.1
end

# Pour définir la tabulation avec le message de success
# Par défaut, elle est composée de deux espaces
def success_tab value = nil
  if value
    @success_tab = value
  else
    @success_tab || '  '
  end
end

def failure message
  verbose? || return
  puts "\e[31m#{success_tab}#{message}\e[0m"
  sleep 0.1
end

def mode_verbose mode
  @mode_verbose = mode
end
def verbose?
  defined?(@mode_verbose) || @mode_verbose = true
  @mode_verbose
end

def remove_debug
  p = './xtmp/debug.log'
  File.exist?(p) && File.unlink(p)
end
