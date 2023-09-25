# define discord stuff
{ Client, Collection, GatewayIntentBits } = require 'discord.js'
client = new Client(intents: [
  GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers,
  GatewayIntentBits.GuildPresences, GatewayIntentBits.MessageContent,
  GatewayIntentBits.GuildMessages
])
token = require './token.json'

# define nodejs stuff
fs = require 'node:fs'
path = require 'node:path'

# handle event registration
registerEvent = (eventName, executeFunction, once = false) ->
  if once 
    client.once eventName, (...args) -> executeFunction(...args)
  else client.on eventName, (...args) -> executeFunction(...args)

# acquire all events files
eventsPath = path.join(__dirname, 'events')
eventFiles = fs.readdirSync(eventsPath).filter (file) -> file.endsWith('.js') or file.endsWith('.coffee')

for file in eventFiles
  filePath = path.join(eventsPath, file)
  event = require filePath

  if event.once
    registerEvent event.name, event.execute, true
  else registerEvent event.name, event.execute

# load all commands files
client.commands = new Collection()

foldersPath = path.join(__dirname, 'commands')
commandFolders = fs.readdirSync(foldersPath)

for folder in commandFolders
  commandsPath = path.join(foldersPath, folder)
  commandFiles = fs.readdirSync(commandsPath).filter (file) -> file.endsWith('.js') or file.endsWith('coffee')

  for file in commandFiles
    filePath = path.join(commandsPath, file)
    command = require filePath

    # set new item in the Collection with the key as command name and value as exported module
    if 'data' of command and 'execute' of command
      client.commands.set command.data.name, command
    else
      console.log "[!] WARNING: The command at #{filePath} is missing a required \"data\" or \"execute\" property."

# login to bot profile on discord
client.login token
