async function main() {
  const deployer = (await ethers.getSigners())[0];
  const updatedEPay = await ethers.getContract("UpdatedEPay", deployer.address);
  console.log("Withdrawing sent ETH back to your account..");
  const transactionResponse = await updatedEPay.withdraw(5);
  await transactionResponse.wait(1);
  console.log("Withdrawed!");
  console.log(`Balance: ${await deployer.getBalance()}`);
  console.log(
    `Amount of sent Ethereum: ${await updatedEPay.s_addressToSentAmount(
      deployer.address
    )}`
  );
  console.log("--------------------------------------");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
