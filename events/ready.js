const { Events } = require('discord.js');

module.exports = {
  name: Events.ClientReady,
  once: true,
  execute(client) { console.log(`Successfully logged in to ${client.user.tag}`); },
}
