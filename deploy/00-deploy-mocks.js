const { network } = require("hardhat")
const { developmentChains, DECEMALS, INITIAL_ANSWER } = require("../helper-hardhat-config")
const { log } = require("ethers")
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    if (developmentChains.includes(network.name)) {
        log("Local network detected! Deploying mocks....")
        await deploy("MockV3Aggregator", {
            contract: "MockV3Aggregator",
            from: deployer,
            log: true,
            args: [DECEMALS, INITIAL_ANSWER]
        })
        log("MOCKS Deployed!")
        log("------------------------------------------------------------------")

    }

}

module.exports.tags = ["all", "mocks"]