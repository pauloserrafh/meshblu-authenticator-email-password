{DeviceAuthenticator} = require 'meshblu-authenticator-core'
MeshbluDB = require 'meshblu-db'
debug = require('debug')('meshblu-email-password-authenticator:device-controller')
_ = require 'lodash'
validator = require 'validator'

class DeviceController
  constructor: (meshbluJSON, @meshblu) ->
    @authenticatorUuid = meshbluJSON.uuid
    @authenticatorName = meshbluJSON.name
    @meshbludb = new MeshbluDB @meshblu

  create: (request, response) =>
    {email,password} = request.body
    return response.status(422).send new Error('Invalid email') unless validator.isEmail(email)

    deviceModel = new DeviceAuthenticator @authenticatorUuid, @authenticatorName, meshblu: @meshblu, meshbludb: @meshbludb
    query = {}
    query[@authenticatorUuid + '.id'] = email
    device =
      type: 'octoblu:user'

    debug 'device query', query
    deviceModel.create query, device, email, password, (error, createdDevice) =>
      if error?
        if error.message == DeviceAuthenticator.ERROR_DEVICE_ALREADY_EXISTS 
          return response.status(401).json error: "Unable to create user"
        return response.status(500).send(error)

      response.status(201).json createdDevice

module.exports = DeviceController
