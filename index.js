const execSync = require('child_process');
const {writeFileSync} = require('fs');

function command(cmd) {
    return execSync(`git ${cmd}`)
}

const package = require('./package.json'); 
package.version = '1.2.3';
console.log(JSON.stringify(package, null, 4))
writeFileSync('./package.json', JSON.stringify(package, null, 4));