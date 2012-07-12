# TODO: put paths in constants
# require modules
child_process = require 'child_process'
spawn = child_process.spawn
express = require 'express'
uglify = require 'uglify-js'
fs = require 'fs'
  

# create express server
app = express.createServer()

# parse args (- coffee and the filename)
ARGV = process.argv[2..]
rargs = /--\w+/
rprod = /^--production/

for s in ARGV
  m = rargs.exec s
  app.env = 'production' if m and m[0] and m[0].match rprod

# express configuration
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.static __dirname + '/public'

ensureIsFile = (f, cb) ->
  fs.stat f, (err, stats) ->
    throw err if err
    if stats.isFile() and not stats.isDirectory()
      cb(f) if cb and typeof cb is 'function'

doMinify = (f) ->
  child_process.exec "./node_modules/.bin/uglifyjs --overwrite #{f}", (err, stdout, stderr) ->
    console.log "error: #{err}" if err

# minify with uglifyjs
initMinification = ->
  fs.readdir './public/js', (err, data) ->
    throw err if err

    for f in data
      ensureIsFile "./public/js/#{f}", doMinify

# watch and compile coffeescript source files
###
child_process.exec './node_modules/.bin/coffee -o public/js -w -c coffee', (error, stdout, stderr) ->
=======
child_process.exec './node_modules/.bin/coffee -o public/js -w -c coffee', (error, stdout, stderr) ->
  console.log "error #{error}" if error
###
coffee = spawn './node_modules/.bin/coffee', ['-o', './public/js',  '-w',  '-c',  './coffee']
coffee.stdout.on 'data', (data) ->
  initMinification() if app.env == 'production'

coffee.on 'exit', (code) ->
  console.log "coffee watcher exited with code: #{code}"

# watch and compile stylus source files
child_process.exec './node_modules/.bin/stylus -w -c styl -o public/css', (error, stdout, stderr) ->
  console.log "error #{error}" if error

# routes
app.get '/', (req, res) ->
  res.render 'index', { title : 'Espresso Boilerplate' }

# start server
app.listen 3000, -> console.log "Express server listening on port %d, (env = %s)", app.address().port, app.env


