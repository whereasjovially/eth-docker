const fs = require('fs');
const path = require('path');

// Base directory where keys are stored
const baseDir = './assigned_data/keys';
const run = async () => {
  let indices = [];
  let credentials = [];
  try {
    // Get all directories inside the baseDir
    const pubkeys = fs.readdirSync(baseDir, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory()) // Only get directories
        .map(dirent => dirent.name); // Extract directory names
    for(let i=0 ; i<pubkeys.length ; i++){
      const pubkey = pubkeys[i];
      const validatorInfo = await await (fetch(`https://ethereum-holesky-beacon-api.publicnode.com/eth/v1/beacon/states/finalized/validators/${pubkey}`).then(res => res.json()))
      indices.push(validatorInfo.data.index);
      credentials.push(validatorInfo.data.validator.withdrawal_credentials);
    }
  } catch (error) {
      console.error("Error reading pubkeys:", error);
  }

  console.log("indices:",indices);
  console.log("credentials:",credentials);

  try {
    const envFilePath = path.join(__dirname, 'secrets.env');
    let envContent = fs.readFileSync(envFilePath, 'utf8');

    envContent = envContent.replace(
      /VALIDATOR_INDICES=".*?"/, 
      `VALIDATOR_INDICES="${indices.join(', ')}"`
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

