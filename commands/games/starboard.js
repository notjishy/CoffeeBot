const { SlashCommandBuilder, EmbedBuilder, userMention, PermissionsBitField } = require('discord.js');
const config = require('../../config.json');
const starboardGame = config.games[0].starboard;
const fs = require('node:fs');

const data = new SlashCommandBuilder()
    .setName('starboard')
    .setDescription('manage starboard game')
    .addSubcommand(subcommand =>
        subcommand
            .setName('leaderboard')
            .setDescription('view the leaderboard for starboard')
    )
    .addSubcommand(subcommand =>
        subcommand
            .setName('removemsg')
            .setDescription('manually remove a message and all of its stars')
            .addStringOption(option =>
                option.setName('message')
                    .setDescription('the message to remove')
                    .setRequired(true)
            )
    );

const execute = function(interaction){
    if (!starboardGame.isEnabled){
        interaction.reply('the starboard game is currently disabled');
        return;
    }

    const subCommand = interaction.options.getSubcommand();

    try {
        var starboardData = JSON.parse(fs.readFileSync('./games/starboard.json', 'utf-8'));
    } catch (error) {
        console.error(error);
    }

    switch (subCommand){
        case 'leaderboard':
            var outputStr = '';
            var isEmpty = true;
            if (starboardData.length <= 0){
                //console.log('starboard empty');
                outputStr = 'nothing has been added to the starboard';
            } else {
                isEmpty = false;
                var leaderboardArray = [];
                for (var v of starboardData){
                    //console.log(`v loop: ${JSON.stringify(v)}`);
                    if (leaderboardArray.length === 0){
                        //console.log('array length 0');
                        leaderboardArray.push(v);
                    } else {
                        const iterationCount = leaderboardArray.length;
                        var continueLoop = true;
                        for (var i = 0; i <= iterationCount && continueLoop == true; i++){
                            //console.log(`i loop: ${i}`);
                            if (leaderboardArray[i].stars < v.stars){
                                //console.log(`${leaderboardArray[i].stars} < ${v.stars}`);
                                leaderboardArray.splice(i, 0, v);
                                continueLoop = false;
                            } else {
                                //console.log(`${leaderboardArray[i].stars} >= ${v.stars}`);
                                leaderboardArray.push(v);
                                continueLoop = false;
                            }
                        }

                        if (leaderboardArray.length === 11){ leaderboardArray.splice(10, 1); }
                    }
                }
            }
            //console.log(JSON.stringify(leaderboardArray));
            if (!isEmpty){
                outputStr = `**top ${leaderboardArray.length}:**\n`;
                for (var i = 1; i <= leaderboardArray.length; i++){
                    outputStr += `**${i}:** ${starboardGame.starboardEmoji}${leaderboardArray[i-1].stars} ${userMention(leaderboardArray[i-1].authorId)}\n`;
                }
            }

            let leaderboardEmbed = new EmbedBuilder()
                .setTitle('starboard leaderboard')
                .setDescription(outputStr)
                .setColor(starboardGame.embedColor)

            interaction.reply({ embeds: [leaderboardEmbed] });
            break;
        case 'removemsg':
            if (interaction.member.permissions.has(PermissionsBitField.Flags.Administrator)){
                // @TODO
                // remove specified message from the starboard
            } else{
                interaction.reply('you do not have permission to do that');
            }
            break;
        default:
            return;
    }
}

module.exports = { data, execute };