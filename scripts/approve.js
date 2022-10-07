const fs = require("fs");
const signatureFile = "./scripts/helper.txt";

async function main() {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const user = accounts[1];
  let updatedEPay = await ethers.getContract("UpdatedEPay", deployer.address);
  console.log("Approve allowance..");
  const approvalTx = await updatedEPay.approve(10, user.address);
  const txReceipt = await approvalTx.wait(1);
  const messageHash = txReceipt.events[0].args._message;
  console.log("Approved!");
  console.log("--------------------------------------");

  //   const deployerWallet = new ethers.Wallet(
  //     "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
  //   );
  const signature = await deployer.signMessage(
    ethers.utils.arrayify(messageHash)
  );
  console.log(signature);
  //   const sig = ethers.utils.splitSignature(signature);
  fs.writeFileSync(signatureFile, signature);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
