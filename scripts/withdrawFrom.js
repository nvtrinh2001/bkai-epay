const fs = require("fs");
const signatureFile = "./scripts/helper.txt";

async function main() {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const user = accounts[1];
  let updatedEPay = await ethers.getContract("UpdatedEPay", deployer.address);

  console.log("Withdrawing..");
  const signature = fs.readFileSync(signatureFile, { encoding: "utf8" });

  updatedEPay = await updatedEPay.connect(user);
  const txResponse = await updatedEPay.withdrawFrom(
    deployer.address,
    10,
    signature
  );
  const txWithdrawalReceipt = await txResponse.wait(1);

  console.log("Withdrawed!");
  console.log(`Balance: ${await user.getBalance()}`);
  console.log(
    `Remaining Ethereum of sender after being withdrawed: ${await updatedEPay.s_addressToSentAmount(
      deployer.address
    )}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
