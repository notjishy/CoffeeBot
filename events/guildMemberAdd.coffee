{ Events, EmbedBuilder } = require 'discord.js'
config = require '../config.json'

name = Events.GuildMemberAdd
execute = (member) ->
  embed = new EmbedBuilder()
    .setColor '#086d24'
    .setTitle member.user.displayName
    .setThumbnail member.user.avatarURL()
    .setDescription 'new member has joined'

  member.guild.channels.cache.get(config.guildJoinLeaveChnl).send embeds: [embed]

module.exports = { name, execute }
