exec = require('child_process').exec

module.exports = () ->
  child = exec "#{__dirname}/../node_modules/grunt-cli/bin/grunt"

  errorMsg = ''
  child.stdout.on 'data', (consoleMsg) ->
    # store all the output
    errorMsg += consoleMsg + '\n'

    consoleMsg = consoleMsg.replace(/\n/g, '')

    if consoleMsg.match(/Warning:/)
      # Find the Stack Trace related to this warning
      stackTrace = errorMsg.substring(errorMsg.lastIndexOf('Running "'))
      console.error 'Grunt :: ' + consoleMsg, stackTrace
      return
    # Throw an error
    else if consoleMsg.match(/Aborted due to warnings./)
      console.error 'Grunt :: ', consoleMsg, stackTrace
      console.error "*-> An error occurred-- please fix it."
    else if consoleMsg.match(/ParseError/)
      console.error 'Grunt :: ', consoleMsg, stackTrace
    else if consoleMsg isnt ''
      console.log 'Grunt :: ' + consoleMsg

  child.stdout.on 'error', (consoleErr) -> console.error 'Grunt :: ' + consoleErr
  child.stderr.on 'data', (consoleErr) -> console.error 'Grunt :: ' + consoleErr
  child.stderr.on 'error', (consoleErr) -> console.error 'Grunt :: ' + consoleErr