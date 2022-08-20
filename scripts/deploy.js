
const hre = require("hardhat");

async function main() {

  const [owner] = await hre.ethers.getSigners();
  const Dao = await hre.ethers.getContractFactory("Dao");
  const dao = await Dao.deploy();

  await dao.deployed();

  console.log(`Dao was deployed to the following address:", ${dao.address}`);
  console.log("Dao owner address:", owner.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
