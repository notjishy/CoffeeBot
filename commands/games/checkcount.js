const { SlashCommandBuilder, EmbedBuilder, channelMention } = require('discord.js');
const config = require('../../config.json');
const fs = require('node:fs');

const data = new SlashCommandBuilder()
    .setName('checkcount')
    .setDescription('manage the counting game or check what number it is');

const execute = function(interaction){
    const isCountingChannel = (interaction.channel.id === config.games[0].counting.channel);
    
    switch (isCountingChannel){
        case true:
            if (!config.games[0].counting.isEnabled){
                interaction.reply('the counting game is currently not enabled');
                return;
            }

            try {
                var countingData = JSON.parse(fs.readFileSync('./games/counting.json', 'utf-8'));
            } catch (error) {
                console.error(`error reading counting.json: ${error}`);
                return;
            }

            let responseEmbed = new EmbedBuilder()
                .setColor('#FFAA00')
                .setAuthor({
                    name: 'counting status:',
                    iconURL: interaction.member.user.avatarURL()
                })
                .setTimestamp();

            for (var element in countingData){
                let value = countingData[element].toString()
                if (value === 'false') { value.replace('false', 'none'); }
                responseEmbed.addFields({
                    name: (element),
                    value: (value),
                    inline: true
                });
            }

            interaction.reply({ embeds: [responseEmbed] });
            break;
        case false:
            interaction.reply(`please run this in the ${channelMention(config.games[0].counting.channel)} channel`);
            break;
        default:
            return;
    }
}

module.exports = { data, execute };