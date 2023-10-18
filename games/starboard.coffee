{ Collection, EmbedBuilder } = require 'discord.js'
fs = require 'node:fs'
config = require '../config.json'
game = config.games[0].starboard

module.exports =
  execute: (reaction, user, addStar) ->
    message = reaction.message

    # fetch uncached message if needed
    if message.partial
      try
        await message.fetch()
      catch error
        console.error 'Error fetching message:', error
        return

    reactions = message.reactions.cache.get(game.starboardEmoji)

    switch addStar
      when true then starboardAddReaction(message, user, reactions)
      else starboardRemoveReaction(message, user, reactions)


# FUNCTIONS
# handles losing star reactions
starboardRemoveReaction = (message, user, reactions) ->
  if user.bot then return

  if not reactions or reactions.count < game.neededReactions
    gameData = getGameData()

    for element in gameData
      if element.channelId is message.channel.id and element.messageId is message.id
        gameData.splice(element)

        message.guild.channels.fetch(game.starboardChannel)
          .then (channel) ->
            channel.messages.delete(element.starboardMsgId)
        break
      else return

    saveGameData(gameData)

# handles gaining star reactions
starboardAddReaction = (message, user, reactions) ->
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
    gameData = getGameData()

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
      "starboardMsgId": starboardMsg.id,
      "stars": reactions.count
    }

    gameData.push(newJson)

    saveGameData(gameData)
  else return

# acquires saved json data
getGameData = () ->
  try
    gameData = JSON.parse fs.readFileSync('./games/starboard.json', 'utf-8')
    return gameData
  catch error
    console.error "error reading starboard.json: #{error}"
    return

# writes saved json data
saveGameData = (gameData) ->
  fs.writeFile('./games/starboard.json', JSON.stringify(gameData, null, 2), (err) ->
    if err
      console.log err
  )