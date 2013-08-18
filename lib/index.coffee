express = require 'express'
http = require 'http'
router = require "#{__dirname}/router"
database = require "#{__dirname}/database"
grunt = require "#{__dirname}/grunt"
MongoStore = require 'connect-session-mongo'
Config = require 'config'

app = express()

# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', "#{process.cwd()}/views"
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser Config.secret ? 'beer'

app.use express.session
  store: new MongoStore url: Config.db

app.use express.static("#{process.cwd()}/public")

# development only
if 'development' is app.get('env')
  app.use express.errorHandler()

database app, "#{process.cwd()}/api/models"

# Load routes located in config/routes.json
app.use app.router
routePath = "#{process.cwd()}/config/routes"
controllerPath = "#{process.cwd()}/api/controllers"
middlewarePath = "#{process.cwd()}/api/middleware"
router(app, routePath, controllerPath, middlewarePath)

grunt()

http.createServer(app).listen app.get('port'), ->
  console.log 'Server running on http://localhost:' + app.get('port')
