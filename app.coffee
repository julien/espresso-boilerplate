child_process = require 'child_process'
express = require 'express'

# create a (express) server
app = express.createServer()
app.configure ->
  app.use express.bodyParser()
  app.use express.static(__dirname + '/public')


# watch and compile coffeescript source files for changes
child_process.exec 'coffee -o public/js -w -c public/cs', (error, stdout, stderr) ->
  console.log "error #{error}" if error

# start server
app.listen 3000, () -> console.log 'server running on %d', app.address().port


