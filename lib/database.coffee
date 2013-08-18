fs = require 'fs'
Config = require 'config'
mongoose = require 'mongoose'
{timestamps} = require 'mongoose-plugins-timestamp'

module.exports = (app, modelPath) ->
  mongoose.connect Config.db
  models = {}
  for file in fs.readdirSync modelPath
    name = file.replace /\..*/g, ''
    schema = require("#{modelPath}/#{file}")(mongoose.Schema)
    schema.plugin timestamps
    mongoose.model name, schema
    models[name] = mongoose.model name

  # Attache middleware
  app.use (req, res, next) ->
    req.models = models
    next()