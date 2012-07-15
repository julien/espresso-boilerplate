#!/usr/bin/env coffee
fs = require 'fs'
os = require 'os'

# script args
args = process.argv.slice 2
path = '.'
app = args[0]
path = app if app

# templates
tpl =
  app:
    """
      ### require modules ###
      express = require 'express'
      espresso = require './espresso.coffee'

      ### create express server ###
      app = express.createServer()


      ### parse args (- coffee and the filename) ###
      ARGV = process.argv[2..]
      rargs = /-{1,2}\w+/
      rprod = /-{1,2}(p|production)/

      for s in ARGV
        m = rargs.exec s
        app.settings.env = 'production' if m and m[0] and m[0].match rprod

      ### express configuration ###
      app.configure ->
        app.set 'views', __dirname + '/views'
        app.set 'view engine', 'jade'
        app.use express.bodyParser()
        app.use express.static __dirname + '/public'


      ### watch coffeescript sources ###
      coffee = espresso.core.exec espresso.core.node_modules_path + 'coffee -o public/js -w -c coffee'
      coffee.stdout.on 'data', (data) ->
        espresso.core.minify() if app.settings.env == 'production'


      ### watch stylus sources ###
      espresso.core.exec espresso.core.node_modules_path + 'stylus -w -c styl -o public/css'


      ### app routes ###
      app.get '/', (req, res) ->
        res.render 'index', { title : 'Espresso Boilerplate' }


      ### start server ###
      app.listen 3000, ->
        espresso.core.logEspresso()
        console.log "Server listening on port %d, %s", app.address().port, app.settings.env
    """

  espresso: """
    child_process = require 'child_process'
    fs = require 'fs'
    isWindows = process.platform.match /win/

    ensureIsFile = (f, cb) ->
      fs.stat f, (err, stats) ->
        throw err if err
        if stats.isFile() and not stats.isDirectory()
          cb(f) if cb and typeof cb is 'function'

    core =
      node_modules_path: if isWindows then 'call node_modules/.bin/' else './node_modules/.bin/'
      exec: (cmd) ->
        std = child_process.exec cmd
        std.stderr.on 'data', (error) ->
          console.log 'error: ' + error
        return std

      minify: ->
          fs.readdir 'public/js', (err, data) ->
            throw err if err

            for f in data
              ensureIsFile 'public/js/' + f, (f) ->
                core.exec core.node_modules_path + 'uglifyjs --overwrite ' + f

      logEspresso: ->
          console.log " ______                                   "
          console.log "|  ____|                                  "
          console.log "| |__   ___ _ __  _ __ ___  ___ ___  ___  "
          console.log "|  __| / __| \'_ \\| \'__/ _ \\/ __/ __|/ _ \\ "
          console.log "| |____\\__ \\ |_) | | |  __/\\__ \\__ \\ (_) |"
          console.log "|______|___/ .__/|_|  \\___||___/___/\\___/ "
          console.log "           | |                            "
          console.log "           |_|                            "

    exports.core = core
  """

  package: """
    {
      "name": "application-name",
      "version": "0.0.1",
      "private": true,
      "scripts": {
        "preinstall": "npm install -g coffee-script"
      },
      "dependencies": {
        "express": "2.5.11",
        "coffee-script": "1.3.3",
        "stylus": "*",
        "jade": "*",
        "uglify-js": "*"
        }
    }
  """
  jade:
    index: """
      h1= title
    """
    layout: """
      !!!
      html
        head
          title= title
        body!= body
    """

# helpers
isFunc = (fn) ->
  s = Object::toString.call fn
  s is '[object Function]'

dirIsEmpty = (path, fn) ->
  fs.readdir path, (err, files) ->
    throw err if err and 'ENOENT' != err.code
    fn(!files || !files.length) if isFunc fn

mkdir = (path, fn) ->
  fs.mkdir path, (err) ->
    throw err if err and err.code != 'EEXIST'
    console.log "  create: #{path}"
    fn(path) if isFunc fn

write = (path, str) ->
  fs.writeFile path, str
  console.log "  create: #{path}"

abort = (msg = '') ->
  console.error msg if msg
  process.exit 1

prompt = (msg, fn) ->
  console.log msg
  process.stdin.setEncoding 'ascii'
  process.stdin.once('data', (data) ->
    fn data if isFunc fn
  ).resume()

confirm = (msg, fn) ->
  prompt msg, (val) ->
    fn /^y(es)?/i.test val

createAppAt = (path) ->
  process.on 'exit', () ->
    console.log ''
    console.log "  dont forget to run cd #{path} && npm install"
    console.log ''

  mkdir "#{path}/public"
  mkdir "#{path}/public/css"
  mkdir "#{path}/public/img"
  mkdir "#{path}/public/js"

  mkdir "#{path}/coffee"
  mkdir "#{path}/styl"
  mkdir "#{path}/views", () ->
    write "#{path}/views/index.jade", tpl.jade.index
    write "#{path}/views/layout.jade", tpl.jade.layout
    write "#{path}/app.coffee", tpl.app
    write "#{path}/espresso.coffee", tpl.espresso
    write "#{path}/package.json", tpl.package

printhelp = ->
  console.log ''
  console.log 'usage espresso "app name"'
  console.log ''


if path == '.'
  printhelp()
  return


# check if the destination path if empty
# if so create the app structure if not
# prompt the user to confirm
#
dirIsEmpty path, (empty) ->
  if empty
    mkdir path, () ->
      createAppAt path
  else
    confirm '  directory is not empty, continue? (y/es)', (ok) ->
      if ok
        process.stdin.destroy()
        createAppAt path
      else
        abort '  aborting'



