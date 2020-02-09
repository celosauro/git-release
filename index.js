import {execSync} from 'child_process';

function command(cmd) {
    return execSync(`git ${cmd}`)
}