const { SlashCommandBuilder } = require('discord.js');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('ping')
        .setDescription('Responds with API Ping and calcuated Bot Latency.'),
    async execute(interaction, client) {
        const apiPing = client.ws.ping;
        const botLatency = Date.now() - interaction.createdTimestamp;
        
        await interaction.reply(`**API Ping:** ${apiPing}ms \n**Bot Latency:** ${botLatency}ms`);
    },
};
