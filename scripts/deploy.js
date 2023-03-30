const { hre, ethers } = require("hardhat");
const { Signer } = require("ethers");
const { hexValue } = require("ethers/lib/utils");

const main = async () => {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    const [deployer] = await ethers.getSigners();
    console.log(`Address deploying the contract --> ${deployer.address}`);

    const addresses = await ethers.provider.listAccounts();

    const clauseNFT = await ethers.getContractFactory("ClauseNFT");
    const clauseNFTcontract = await clauseNFT.deploy("ClauseNFT", "CNFT", "https://ipfs.io/ipfs/bafybeiga2eqphsueydfygb2ueqdtslrwyvljqahcteyg26f6q6yic6u3vm/{id}.json");

    console.log(`ClauseNFT Contract address --> ${clauseNFTcontract.address}`);

    const shareToken = await ethers.getContractFactory("ShareToken");
    //const shareTokenContract = await shareToken.deploy("ShareToken", "STK");
    const shareTokenContract = await shareToken.deploy();


    console.log(`ShareToken Contract address --> ${shareTokenContract.address}`);
}