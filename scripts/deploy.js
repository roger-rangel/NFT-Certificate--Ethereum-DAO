
const hre = require("hardhat");

async function main() {

  const daoedAmount = hre.ethers.utils.parseEther("1");

  const Dao = await hre.ethers.getContractFactory("Dao");
  const dao = await Dao.deploy();

  await dao.deployed();

  console.log(
    `Dao with 1 ETH deployed to ${dao.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
