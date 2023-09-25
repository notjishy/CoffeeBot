fs = require 'node:fs'

### @TODO: 
add check to make sure users cannot go twice in a row
add reactions to confirm correct numbers that saved properly, denied/incorrect numbers, etc
###
module.exports =
  execute: (message) ->
    try
      countingState = fs.readFileSync('./games/counting.json', 'utf-8')
      count = parseInt(countingState)
    catch error
      console.error "error reading counting.json: #{error}"
      return

    isInteger = not isNaN(parseInt message.content) and parseInt(message.content) is parseFloat message.content
    if isInteger
      num = parseInt(message.content)
      
      if num is count + 1
        try
          fs.writeFileSync('./games/counting.json', JSON.stringify(num))
          console.log "updated counting.json to #{num}"
        catch error
          console.log "error writing to counting.json: #{error}"
      else
        console.log 'invalid number'
    else
      console.log 'message is not an integer'
