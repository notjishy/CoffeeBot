{ SlashCommandBuilder, EmbedBuilder } = require 'discord.js'
botPackage = require '../../package.json'

data = new SlashCommandBuilder()
  .setName 'botinfo'
  .setDescription 'responds with current information on CoffeeBot\'s status.'

execute = (interaction) ->
  apiPing = interaction.client.ws.ping
  botLatency = Date.now() - interaction.createdTimestamp

  responseEmbed = new EmbedBuilder()
    .setColor interaction.member.roles.highest.color
    .setTitle 'bot info'
    .setURL 'https://github.com/notjishy/CoffeeBot/blob/main/commands/utils/botinfo.coffee'
    .setAuthor
      name: interaction.member.displayName
      iconURL: interaction.member.user.avatarURL()
    .addFields
      name: 'api ping:'
      value: "#{apiPing}ms"
      inline: true
    .addFields
      name: 'bot latency:'
      value: "#{botLatency}ms"
      inline: true
    .addFields
      name: 'bot version:'
      value: botPackage.version
      inline: true
    .setTimestamp()

  interaction.reply embeds: [responseEmbed]

module.exports = { data, execute }