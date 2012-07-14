{exec} = require 'child_process'
lib = 'lib'
src = 'espresso'

task 'build', 'Compiles the CoffeeScript source to JavaScript', () ->
  exec "coffee -c -o #{lib} #{src}.coffee", (err, stdout, stderr) ->
    throw err if err
    console.log "#{src}.coffee compiled to #{lib}/#{src}.js"

