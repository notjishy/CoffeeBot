const { SlashCommandBuilder, EmbedBuilder, AttachmentBuilder } = require('discord.js');
const config = require('../../config.json');
const coinflip = config.games[0].coinflip

const data = new SlashCommandBuilder()
    .setName('coinflip')
    .setDescription('flip a coin to decide your fate');

const execute = function(interaction){
    if (!coinflip.isEnabled){
        interaction.reply('this command is not enabled, sorry');
        return;
    }

    const options = ["heads", "tails"];
    const random = options[Math.floor(Math.random() * options.length)];

    const attachment = new AttachmentBuilder()
        .setFile('./assets/a-certain-scientific-railgun-coinflip.gif')
        .setName('coinflip.gif');

    var emoji;
    switch(coinflip.emoji.isAnimated){
        case true:
            emoji = `<a:${coinflip.emoji.name}:${coinflip.emoji.id}>`
            break;
        case false:
            emoji = `<:${coinflip.emoji.name}:${coinflip.emoji.id}>`
    }

    const embed = new EmbedBuilder()
        .setColor('#FFAA00')
        .setTitle(`${emoji} ${random}!`)
        .setAuthor({
            name: `${interaction.member.user.displayName} is flipping a coin.`,
            iconURL: interaction.member.user.avatarURL()
        })
        .setImage('attachment://coinflip.gif')
        .setTimestamp();

        interaction.reply({ embeds: [embed], files: [attachment] });
}

module.exports = { data, execute }