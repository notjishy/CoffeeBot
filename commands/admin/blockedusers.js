const { SlashCommandBuilder, PermissionsBitField } = require('discord.js');
const fs = require('node:fs');

const data = new SlashCommandBuilder()
    .setName('blockedusers')
    .setDescription('adds a user to the blocked users for counting game')
    .addUserOption(option =>
        option.setName('target')
            .setDescription('user to target')
            .setRequired(true)
    )
    .addStringOption(option =>
        option.setName('addorremove')
            .setDescription('choose to add or remove user')
            .setRequired(true)
            .addChoices(
                { name: 'add', value: '+' },
                { name: 'remove', value: '-' }
            )
    );

const execute = function(interaction){
    if (interaction.member.permissions.has(PermissionsBitField.Flags.Administrator)){
        const target = interaction.options.getUser('target');
        const addOrRemove = interaction.options.getString('addorremove');

        let blockedUsers = loadData();

        let foundTarget = false;
        for (const user of blockedUsers){
            if (user === target.id){ foundTarget = true; }
        }

        switch (addOrRemove){
            case '+':
                if (foundTarget){ interaction.reply('that user is already in the blocked list'); return; }

                blockedUsers.push(target.id);
                interaction.reply(`${target} has been added to blocked users`);
                break;
            case '-':
                if (!foundTarget){ interaction.reply('that user is not in the blocked list'); return; }

                blockedUsers = blockedUsers.filter(function(v){
                    return v !== (target.id);
                });
                interaction.reply(`${target} has been removed from blocked users`);
                break;
            default:
                return;
        }

        saveData(blockedUsers);
    } else {
        interaction.reply('you do not have permission to do that');
    }
}

module.exports = { data, execute };

// FUNCTIONS
const loadData = function(){
    try{
        blockedUsers = JSON.parse(fs.readFileSync('./games/blockedUsers.json', 'utf-8'));
        return(blockedUsers);
    } catch (error){
        console.error(`error reading blockedUsers.json: ${error}`);
        return;
    }
}

const saveData = function(data){
    return fs.writeFile('./games/blockedUsers.json', JSON.stringify(data), function(err){
        if (err){ return console.log(err); }
    });
}
