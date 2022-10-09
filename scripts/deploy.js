async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const PiraDex = await ethers.getContractFactory("PiraDex","Ahooy");
  const piraDex = await PiraDex.deploy("PiraDex","Ahooy");

  console.log("Token address:", piraDex.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });