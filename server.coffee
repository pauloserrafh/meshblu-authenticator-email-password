express      = require 'express'
morgan       = require 'morgan'
errorHandler = require 'errorhandler'
bodyParser   = require 'body-parser'
cors         = require 'cors'
MeshbluDB    = require 'meshblu-db'
Routes       = require './app/routes'
meshbluHealthcheck = require 'express-meshblu-healthcheck'

try
  meshbluJSON  = require './meshblu.json'
catch
  meshbluJSON =
    uuid:   process.env.EMAIL_PASSWORD_AUTHENTICATOR_UUID
    token:  process.env.EMAIL_PASSWORD_AUTHENTICATOR_TOKEN
    server: process.env.MESHBLU_HOST
    port:   process.env.MESHBLU_PORT
    name:   'Email Authenticator'

port = process.env.EMAIL_PASSWORD_AUTHENTICATOR_PORT ? process.env.PORT ? 80

app = express()
app.use morgan('dev')
app.use errorHandler()
app.use meshbluHealthcheck()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cors()

meshbludb = new MeshbluDB meshbluJSON

meshbludb.findOne uuid: meshbluJSON.uuid, (error, device) ->
  console.error error.message, error.stack if error?
  console.log "I am #{device.uuid}"
  meshbludb.setPrivateKey(device.privateKey) unless meshbludb.privateKey

routes = new Routes app, meshbluJSON, meshbludb
routes.register()

app.listen port, =>
  console.log "listening at localhost:#{port}"
