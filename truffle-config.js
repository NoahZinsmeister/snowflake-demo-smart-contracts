const gas = 4000000 // 650,000 gas limit
const gasPrice = 2000000000 // 2 gwei

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*',
      gas: gas,
      gasPrice: gasPrice
    },
    rinkebyIPC: {
      host: 'localhost',
      port: 8545,
      network_id: 4,
      timeoutBlocks: 200,
      gas: gas,
      gasPrice: gasPrice,
      skipDryRun: true
    }
  },
  compilers: {
    solc: {
      version: '0.5.0',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
}
