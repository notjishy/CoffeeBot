{ EmbedBuilder } = require 'discord.js'
fs = require 'node:fs'
config = require '../config.json'
game = config.games[0].counting

module.exports =
  execute: (message) ->
    try
      gameData = JSON.parse fs.readFileSync('./games/counting.json', 'utf-8')
      blockedUsers = JSON.parse fs.readFileSync('./games/blockedUsers.json', 'utf-8')
    catch error
      console.error "error reading json: #{error}"
      return

    for user in blockedUsers
      return if user is message.author.id

    isInteger = not isNaN(parseInt message.content) and parseInt(message.content) is parseFloat(message.content)

    if isInteger
      # make sure user did not go twice in a row
      if not game.allowRepeatUsers and message.author.id is gameData.latestUser
        message.reply 'someone else must count the next number'
        message.react game.denyNumber
        return

      num = parseInt(message.content)
      
      if num is gameData.count + 1
        newJson = { "count": num, "highScore": gameData.highScore, "latestUser": message.author.id }

        try
          fs.writeFileSync('./games/counting.json', JSON.stringify(newJson))
          console.log "updated counting.json to #{num}"
        catch error
          console.log "error writing to counting.json: #{error}"
          return
        message.react game.confirmNumber
      else
        message.reply 'incorrect number. resetting progress to 0...'
        message.react game.denyNumber

        if gameData.count > gameData.highScore
          gameData.highScore = gameData.count
          newHighEmbed = new EmbedBuilder()
            .setColor '#FFAA00'
            .setTitle 'new high score'
            .setDescription "the new counting high score is: **#{gameData.highScore}**! 🎉"
          message.channel.send({ embeds: [newHighEmbed] })
        newJson = { "count": 0, "highScore": gameData.highScore, "latestUser": false }

        try
          fs.writeFileSync('./games/counting.json', JSON.stringify(newJson))
        catch error
          console.log "error writing to counting.json: #{error}"
        return
