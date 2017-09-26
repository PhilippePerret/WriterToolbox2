#!/usr/bin/env ruby
# encoding: UTF-8
begin
  require './lib/_required'
  site.output
  # Note : Le programme ne passera en fait jamais par ici
rescue Exception => e
  STDOUT.write "Content-type: text/html; charset: utf-8;\n\n"
  STDOUT.write "<div style='padding:3em;font-size:15.2pt;color:red;'>"
  STDOUT.write "<div style='margin-bottom:2em'>#{e.message}</div>"
  STDOUT.write e.backtrace.collect{|m| "<div>#{m}</div>"}.join('')
  STDOUT.write '</div>'
  STDOUT.write Debug.output rescue nil
end
