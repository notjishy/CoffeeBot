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

    # build starboard channel embed
    if reactions.count >= game.neededReactions
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

      starboardChannel.send({ content: "#{game.starboardEmoji}**#{reactions.count}**", embeds: [boardEmbed] })
