const fs = require('fs');
const path = require('path');

// Base directory where keys are stored
const baseDir = './assigned_data/keys';
const run = async () => {

  let credentialsObj = {};
  let credentials = [];
  let indecies = [];

  try {
    // Get all directories inside the baseDir
    const pubkeys = fs.readdirSync(baseDir, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory()) // Only get directories
        .map(dirent => dirent.name); // Extract directory names
    for(let i=0 ; i<pubkeys.length ; i++){
      const pubkey = pubkeys[i];
      const validatorInfo = await await (fetch(`https://ethereum-holesky-beacon-api.publicnode.com/eth/v1/beacon/states/finalized/validators/${pubkey}`).then(res => res.json()))
      credentialsObj[validatorInfo.data.index] = validatorInfo.data.validator.withdrawal_credentials;
      indecies.push(validatorInfo.data.index)
    }
  } catch (error) {
      console.error("Error reading pubkeys:", error);
  }
  indecies.sort((a,b) => a-b);

  for(let i=0 ; i<indecies.length ; i++){
    credentials.push(credentialsObj[indecies[i]])
  }
  console.log(indecies)
  try {
    const envFilePath = path.join(__dirname, 'secrets.env');
    let envContent = fs.readFileSync(envFilePath, 'utf8');

    envContent = envContent.replace(
      /VALIDATOR_INDICES=".*?"/, 
      `VALIDATOR_INDICES="${indecies.join(', ')}"`
    );

    envContent = envContent.replace(
      /WITHDRAWALS_CREDENTIALS=".*?"/, 
      `WITHDRAWALS_CREDENTIALS="${credentials.join(', ')}"`
    );

    fs.writeFileSync(envFilePath, envContent, 'utf8');

    console.log("Updated secrets.env successfully!");
  } catch (error) {
    console.error("Error updating secrets.env:", error);
  }

}

run()

