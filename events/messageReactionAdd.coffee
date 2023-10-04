{ Events } = require 'discord.js'
config = require '../config.json'
starboard = config.games[0].starboard
starboardGame = require '../games/starboard.coffee'

name = Events.MessageReactionAdd
execute = (reaction, user) ->
  if starboard.isEnabled and reaction.emoji.name is starboard.starboardEmoji
    starboardGame.execute reaction, user

module.exports = { name, execute }