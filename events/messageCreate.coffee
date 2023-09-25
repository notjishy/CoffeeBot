{ Events } = require 'discord.js'
config = require '../config.json'
countingGame = require '../games/counting.coffee'
filtered = false
enabledGames = []

name = Events.MessageCreate
execute = (message) ->
  filterEnabledGames = (config) ->
    for game in config.games
      gameData = game[Object.keys(game)[0]]
      if gameData["isEnabled"] and gameData["requiresChatListener"]
        enabledGames.push game
    return enabledGames

  # Check if message is from a bot
  return if message.author.bot

  # Check if message needs to be sent to a game file
  if not filtered
    enabledGames = filterEnabledGames(config)
    filtered = true

  # Check if message is for a game in a specific channel
  if enabledGames.length > 0
    for game in enabledGames
      gameName = Object.keys(game)[0]
      gameData = game[gameName]
      channel = gameData["channel"]

      if channel
        if message.channel.id is channel
          console.log "received message for #{gameName} in the specified channel: #{message.content}"

          countingGame.execute message

module.exports = { name, execute }
