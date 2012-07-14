#!/usr/bin/env node

fs = require 'fs'
os = require 'os'

# script args
args = process.argv.slice 2
path = '.'
app = args[0]
path = app if app

# templates
tpl =
  app: fs.readFileSync('./tpl/app.coffee').toString()
  espresso: fs.readFileSync('./tpl/espresso.coffee').toString()
  package: fs.readFileSync('./tpl/package.json').toString()
  jade:
    index: fs.readFileSync('./tpl/index.jade').toString()
    layout: fs.readFileSync('./tpl/layout.jade').toString()

# helpers
isFunc = (fn) ->
  s = Object::toString.call fn
  s is '[object Function]'

dirIsEmpty = (path, fn) ->
  fs.readdir path, (err, files) ->
    throw err if err and 'ENOENT' != err.code
    fn(!files || !files.length) if isFunc fn

mkdir = (path, fn) ->
  fs.mkdir path, '0755', (err) ->
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

# check if the destinatio path if empty
# if so create the app structure if not
# prompt the user to confirm
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





