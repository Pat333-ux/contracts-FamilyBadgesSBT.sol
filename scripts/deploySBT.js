const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying FamilyBadgesSBT with account:", deployer.address);

  const baseURI = "https://api.munisible.org/metadata/sbt/";
  const FamilyBadgesSBT = await hre.ethers.getContractFactory("FamilyBadgesSBT");
  const sbt = await FamilyBadgesSBT.deploy(baseURI, deployer.address);

  await sbt.waitForDeployment();
  const address = await sbt.getAddress();

  console.log("FamilyBadgesSBT deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
