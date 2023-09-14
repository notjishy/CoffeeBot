const { SlashCommandBuilder } = require('discord.js');
const { EmbedBuilder } = require('discord.js');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('ping')
        .setDescription('Responds with API Ping and calcuated Bot Latency.'),
    async execute(interaction, client) {
        const apiPing = client.ws.ping;
        const botLatency = Date.now() - interaction.createdTimestamp;

        const responseEmbed = new EmbedBuilder()
            .setColor(interaction.member.roles.highest.color)
            .setTitle('Ping and latency information')
            .setURL('https://github.com/notjishy/CoffeeBot/blob/main/commands/status/ping.js')
            .setAuthor({ name: interaction.member.displayName, iconURL: interaction.member.user.avatarURL() })
            .setDescription(`View the API Ping and Bot Latency times. \nClick the title above to see how its calculated.`)
            .addFields({ name: 'API Ping:', value: `${apiPing}ms`, inline: true })
            .addFields({ name: 'Bot Latency:', value: `${botLatency}ms`, inline: true })
            .setTimestamp()
            
        
        await interaction.reply({ embeds: [responseEmbed] });
    },
};
