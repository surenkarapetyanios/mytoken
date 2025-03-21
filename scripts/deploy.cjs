const hre = require("hardhat");
const { parseUnits } = require("ethers");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying from:", deployer.address);

  const Token = await hre.ethers.getContractFactory("MyToken");
  const token = await Token.deploy("MyToken", "MTK", parseUnits("1000000", 18));

  await token.waitForDeployment();
  console.log("Deployed to:", await token.getAddress());
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
