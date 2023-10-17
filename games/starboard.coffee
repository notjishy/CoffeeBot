{ Collection, EmbedBuilder } = require 'discord.js'
fs = require 'node:fs'
config = require '../config.json'
game = config.games[0].starboard

module.exports =
  execute: (reaction, user) ->
    message = reaction.message

    # fetch uncached message if needed
    if message.partial
      try
        await message.fetch()
      catch error
        console.error 'Error fetching message:', error
        return

    reactions = message.reactions.cache.get(game.starboardEmoji)

    # prevent self-reactions if disallowed in config
    if not game.allowSelfReact and message.author.id is user.id
      response = await message.reply 'self-reactions are disabled for starboard'
      reactions.users.remove(user.id)

      setTimeout ->
        response.delete()
      , 6500
      return

    if reactions.count >= game.neededReactions
      # get guild's starboard data
      try
        gameData = JSON.parse fs.readFileSync('./games/starboard.json', 'utf-8')
        board = gameData
      catch error
        console.error "error reading starboard.json: #{error}"
        return

      # build starboard embed
      starboardChannel = await message.guild.channels.fetch(game.starboardChannel)

      boardEmbed = new EmbedBuilder()
        .setColor(game.embedColor)
        .setDescription("#{message.content}\n[jump to message](#{message.url})")
        .setAuthor
          name: user.displayName
          iconURL: user.avatarURL()
        .setTimestamp()

      attachment = message.attachments.first()?.url
      if attachment then boardEmbed.setImage(attachment)

      starboardMsg = await starboardChannel.send({ content: "#{game.starboardEmoji}**#{reactions.count}**", embeds: [boardEmbed] })

      # save new data
      newJson = {
        "authorId": user.id,
        "channelId": message.channel.id,
        "messageId": message.id,
        "starboardMsgId": starboardMsg.url,
        "stars": reactions.count
      }

      board.push(newJson)

      fs.writeFile('./games/starboard.json', JSON.stringify(gameData, null, 2), (err) ->
        if err
          console.log err
      )