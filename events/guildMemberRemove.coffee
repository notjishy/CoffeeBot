{ Events, EmbedBuilder } = require 'discord.js'
config = require '../config.json'

name = Events.GuildMemberRemove
execute = (member) ->
  embed = new EmbedBuilder()
    .setColor '#a36f6f'
    .setTitle member.user.displayName
    .setThumbnail member.user.avatarURL()
    .setDescription 'member has left'

  member.guild.channels.cache.get(config.guildJoinLeaveChnl).send embeds: [embed]

module.exports = { name, execute }
