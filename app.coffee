### require modules ###
child_process = require 'child_process'
express = require 'express'
uglify = require 'uglify-js'
fs = require 'fs'
isWindows = process.platform.match /win/
node_modules_path = if isWindows then 'call node_modules\\.bin\\' else './node_modules/.bin/'
exec = (cmd) ->
  std = child_process.exec cmd
  std.stderr.on 'data', (error) ->
    console.log "error: #{error}"
  return std


### create express server ###
app = express.createServer()


### parse args (- coffee and the filename) ###
ARGV = process.argv[2..]
rargs = /-{1,2}\w+/
rprod = /-{1,2}(p|production)/

for s in ARGV
  m = rargs.exec s
  app.env = 'production' if m and m[0] and m[0].match rprod

console.log app.env
### express configuration ###
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.static __dirname + '/public'


### minify stuff ###
ensureIsFile = (f, cb) ->
  fs.stat f, (err, stats) ->
    throw err if err
    if stats.isFile() and not stats.isDirectory()
      cb(f) if cb and typeof cb is 'function'

doMinify = (f) ->
  exec "#{node_modules_path}uglifyjs --overwrite #{f}"

initMinification = ->
  fs.readdir 'public/js', (err, data) ->
    throw err if err

    for f in data
      ensureIsFile "public/js/#{f}", doMinify


### watch coffeescript sources ###
coffee = exec "#{node_modules_path}coffee -o public/js -w -c coffee"
coffee.stdout.on 'data', (data) ->
  initMinification() if app.env == 'production'


### watch stylus sources ###
exec "#{node_modules_path}stylus -w -c styl -o public/css"


### app routes ###
app.get '/', (req, res) ->
  res.render 'index', { title : 'Espresso Boilerplate' }


### start server ###
app.listen 3000, ->
  console.log ' ______                                   '
  console.log '|  ____|                                  '
  console.log '| |__   ___ _ __  _ __ ___  ___ ___  ___  '
  console.log '|  __| / __| \'_ \\| \'__/ _ \\/ __/ __|/ _ \\ '
  console.log '| |____\\__ \\ |_) | | |  __/\\__ \\__ \\ (_) |'
  console.log '|______|___/ .__/|_|  \\___||___/___/\\___/ '
  console.log '           | |                            '
  console.log '           |_|                            '
  console.log "Server listening on port %d", app.address().port
