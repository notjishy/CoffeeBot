// define discord stuff
const { Client, Collection, Events, GatewayIntentBits } = require('discord.js');
const client = new Client({ intents: [GatewayIntentBits.Guilds] });
const token = require('./token.json');

// define nodejs stuff
const fs = require('node:fs');
const path = require('node:path');

// load commands
client.commands = new Collection();

const foldersPath = path.join(__dirname, 'commands');
const commandFolders = fs.readdirSync(foldersPath);

for (const folder of commandFolders) {
    const commandsPath = path.join(foldersPath, folder);
    const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));

    for (const file of commandFiles) {
        const filePath = path.join(commandsPath, file);
        const command = require(filePath);

        // set new item in the Collection with the key as command name and value as exported module
        if ('data' in command && 'execute' in command) {
            client.commands.set(command.data.name, command);
        } else {
            console.log(`[!] WARNING: The command at ${filePath} is missing a required "data" or "execute" property.`);
        }
    }
}

// notify when client turns on
client.on('ready', () => { console.log('CoffeeBot Active') });

// command interaction handler
client.on(Events.InteractionCreate, async interaction => {
    if (!interaction.isChatInputCommand()) return;
    
    const command = interaction.client.commands.get(interaction.commandName);

    if (!command) {
        console.error(`No command matching ${interaction.commandName} was found.`);
        return;
    }

    try {
        await command.execute(interaction, client);
    } catch (error) {
        console.error(error);
        if (interaction.replied || interaction.deferred) {
            await interaction.followUp({ content: 'There was an error while executing this command!', ephemeral: true  });
        } else {
            await interaction.reply({ content: 'There was an error while executing this command!', ephemeral: true });
        } 
    }
});

// login to bot profile on discord
client.login(token.token);
