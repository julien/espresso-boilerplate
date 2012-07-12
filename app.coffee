# require modules
child_process = require 'child_process'
express = require 'express'

# create express server
app = express.createServer()

# express configuration
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.static __dirname + '/public'

# watch and compile coffeescript source files
child_process.exec './node_modules/coffee-script/bin/coffee -o public/js -w -c coffee', (error, stdout, stderr) ->
  console.log "error #{error}" if error

# watch and compile stylus source files
child_process.exec './node_modules/stylus/bin/stylus -w -c styl -o public/css', (error, stdout, stderr) ->
  console.log "error #{error}" if error

# routes
app.get '/', (req, res) ->
  res.render 'index', { title : 'Espresso Boilerplate' }

# start server
app.listen 3000, -> console.log "Express server listening on port %d", app.address().port


