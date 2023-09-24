{ Events } = require 'discord.js'

module.exports =
  name: Events.InteractionCreate
  execute: (interaction) ->
    return unless interaction.isChatInputCommand()

    command = interaction.client.commands.get interaction.commandName

    if not command
      console.error "No command matching #{interaction.commandName} was found."
      return

    try
      await command.execute interaction
    catch error
      console.error error
      if interaction.replied or interaction.deferred
        await interaction.followUp
          content: 'There was an error while executing this command!'
          ephemeral: true
      else
        await interaction.reply
          content: 'There was an error while executing this command!'
          ephemeral: true