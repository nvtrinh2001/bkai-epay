async function main() {
  const deployer = (await ethers.getSigners())[0];
  const updatedEPay = await ethers.getContract("UpdatedEPay", deployer.address);
  console.log("Sending fund..");
  const transactionResponse = await updatedEPay.send({
    value: ethers.utils.parseEther("25"),
  });
  await transactionResponse.wait(1);
  console.log("Funded!");
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
