{ Collection, EmbedBuilder } = require 'discord.js'
fs = require 'node:fs'
config = require '../config.json'
game = config.games[0].starboard

module.exports =
  execute: (reaction, user) ->
    # fetch uncached message if needed
    if reaction.message.partial
      try
        await reaction.message.fetch()
      catch error
        console.error 'Error fetching message:', error
        return

    reactions = reaction.message.reactions.cache.get(game.starboardEmoji)

    # prevent self-reactions if disallowed in config
    if not game.allowSelfReact and reaction.message.author.id is user.id
      response = await reaction.message.reply 'self-reactions are disabled for starboard'
      reactions.users.remove(user.id)

      setTimeout ->
        response.delete()
      , 6500
      return

    # build starboard channel embed
    if reactions.count >= game.neededReactions
      starboardChannel = await reaction.message.guild.channels.fetch(game.starboardChannel)

      boardEmbed = new EmbedBuilder()
        .setColor(game.embedColor)
        .setDescription("#{reaction.message.content}\n[jump to message](https://discord.com/channels/#{reaction.message.guild.id}/#{reaction.message.channel.id}/#{reaction.message.id})")
        .setAuthor
          name: user.displayName
          iconURL: user.avatarURL()
        .setTimestamp()

      starboardChannel.send({ content: "#{game.starboardEmoji}**#{reactions.count}**", embeds: [boardEmbed] })
