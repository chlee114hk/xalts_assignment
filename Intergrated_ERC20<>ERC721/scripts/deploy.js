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
    console.log("Account balance:", ethers.utils.formatEther(await deployer.getBalance()));

    const addresses = await ethers.provider.listAccounts();

    const clauseNFT = await ethers.getContractFactory("ClauseNFT");
    const clauseNFTcontract = await clauseNFT.deploy("ClauseNFT", "CNFT", "https://ipfs.io/ipfs/bafybeiga2eqphsueydfygb2ueqdtslrwyvljqahcteyg26f6q6yic6u3vm/{id}.json");
    await clauseNFTcontract.deployed();

    console.log(`ClauseNFT Contract address --> ${clauseNFTcontract.address}`);

    tx = await clauseNFTcontract.mint(deployer.address, 1);
    await tx.wait(1);
    console.log(`Owner of ClauseNFT #1: ${await clauseNFTcontract.ownerOf(1)})`);

    const shareToken = await ethers.getContractFactory("ShareToken");
    //const shareTokenContract = await shareToken.deploy("ShareToken", "STK");
    const shareTokenContract = await shareToken.deploy();
    await shareTokenContract.deployed();
    console.log(`ShareToken Contract address --> ${shareTokenContract.address}`);

    tx = await clauseNFTcontract.approve(shareTokenContract.address, 1);
    await tx.wait(1);
    console.log("ShareToken Contract approved");

    tx = await shareTokenContract.initialize("ShareToken", "STK", clauseNFTcontract.address, 1);
    await tx.wait(1);
    console.log("ShareToken initialized");
    console.log(`Owner of ClauseNFT #1: ${await clauseNFTcontract.ownerOf(1)})`);

    decimal = await shareTokenContract.decimals();

    tx = await shareTokenContract.mint(addresses[0], ethers.utils.parseUnits("1", decimal));
    await tx.wait(1);

    const erc20 = await shareTokenContract.balanceOf(addresses[0]);
    console.log(`ShareToken Balance of ${addresses[0]}: `, ethers.utils.formatUnits(erc20, decimal));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});