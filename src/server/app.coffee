express = require 'express'
fs = require 'fs'
yaml = require 'js-yaml'
mongoose = require 'mongoose'
bodyParser = require 'body-parser'

app = express()

mongoose.connect 'mongodb://localhost/easyCircosDB'
db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
app.use '/bower_components', express.static 'bower_components'
app.use '/', express.static 'www/client'
app.use bodyParser.json()

db.once 'open', ->
  model = require('./database/model.js').model mongoose

  # if layout collection is empty, import fixtures
  # model.Layout.count (error, count) ->
    # if count == 0
  model.Layout.remove {}, ->
    model.Layout.create require('./database/fixtures/layouts/catalog.js').data

  model.Track.remove {}, ->
    model.Track.create require('./database/fixtures/tracks/catalog.js').data

  model.News.remove {}, ->
    model.News.create require('./database/fixtures/news/news.js').data

  # define routes
  require('./database/layoutManager.js').init app, model.Layout
  require('./database/tracksManager.js').init app, model.Track
  require('./database/proposition.js').init app, model.Proposition
  require('./database/news.js').init app, model.News

app.listen 3000
