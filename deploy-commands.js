require('coffeescript/register');

const { REST, Routes } = require('discord.js');
const { clientId, guildId } = require('./config.json');
const token = require('./token.json');

const fs = require('node:fs');
const path = require('node:path');

const commands = [];
// grab command files from the commands directory
const foldersPath = path.join(__dirname, 'commands');
const commandFolders = fs.readdirSync(foldersPath);

for (const folder of commandFolders) {
    const commandsPath = path.join(foldersPath, folder);
    const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js') || file.endsWith('.coffee'));
    
    // grab SlashCommandsBuilder#toJSON() output of each command's data
    for (const file of commandFiles) {
        const filePath = path.join(commandsPath, file);
        const command = require(filePath);
        
        if ('data' in command && 'execute' in command) {
            commands.push(command.data.toJSON());
        } else {
            console.log(`[!] WARNING: The command at ${filePath} is missing a required "data" or "execute" property.`);
        }
    }
}

// construct and repair an instance of REST module
const rest = new REST().setToken(token.token);

// deplay commands
(async () => {
    try {
        console.log(`Started refreshing ${commands.length} slash commands.`);

        const data = await rest.put(
            Routes.applicationGuildCommands(clientId, guildId),
            { body: commands },
        );

        console.log(`Successfully reloaded ${data.length} slash commands.`);
    } catch (error) {
        console.log(error);
    }
})();
