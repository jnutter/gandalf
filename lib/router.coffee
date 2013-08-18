fs = require 'fs'

controllers = {}
middleware = {}

loadResource = (path, resource) ->
  files = fs.readdirSync path
  for file in files
    if resource is 'middleware'
      name = file.replace(/\..*/g, '')
      middleware[name] = require "#{path}/#{file}"
    else if file.indexOf('Controller.') > 0
      name = file.replace(/Controller\..*/g, '')
      controllers[name] = require "#{path}/#{file}"

bindRoutes = (app, routePath) ->
  routes = require routePath
  for route, chain of routes
    chain = [chain] unless chain instanceof Array

    callbacks = []

    for link in chain
      link = link.split('.')
      if link.length is 1
        callbacks.push(middleware[link[0]])
      else if link.length is 2
        callbacks.push(controllers[link[0]][link[1]])

    route = route.split ' '
    method = if route.length is 1 then 'get' else route[0].toLowerCase()
    path = if route.length is 1 then route[0] else route[1]

    app[method](path, callbacks)


module.exports = (app, routePath, controllerPath, middlewarePath = false) ->
  loadResource(controllerPath, 'controller')
  loadResource(middlewarePath, 'middleware') if middlewarePath
  bindRoutes(app, routePath)