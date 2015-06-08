##################################
#   SYS-API (c) 2015 - Burnett
##################################

restify = require 'restify'

AddonHelper = require './AddonHelper'

Fs = require './addons/Fs/Fs'
Os  = require './addons/Os/Os'
Net = require './addons/Net/Net'

class API extends AddonHelper

    @include Fs
    @include Os
    @include Net

    constructor: (options) ->
        @server = new restify.createServer(options);

    connect: (port) ->
        @server.listen port, () ->
            console.log('API listening on port %d', port);
        
    auth: (options) ->
        options = options || { enabled: false }
        
        if options.enabled == true
            @server.use(restify.authorizationParser())
            
            if options.method == 'basic' || options.hasOwnProperty('users')
                users = options.users
                
                @server.use((req, res, next) ->
                    if req.username == 'anonymous' || !users[req.username] || req.authorization.basic.password != users[req.username].password
                        next(new restify.NotAuthorizedError())
                    else
                        return next()
                )
 
    head: (path, handlers...) ->
      @server.head(path, handlers)
        
    get: (path, handlers...) ->
      @server.get(path, handlers)
      
    post: (path, handlers...) ->
      @server.post(path, handlers)
     
    response: (req, res, next, x) ->
        response = {}
        
        if x.err? && x.err != ''   
            response.err = x.err
        else
            response.data = x
              
        res.send({ response: response });
        return next();
        

module.exports = API
