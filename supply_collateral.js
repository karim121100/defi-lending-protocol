const { ethers } = require("hardhat");
const config = require("./lending_config.json");

async function main() {
    const [user] = await ethers.getSigners();
    const pool = await ethers.getContractAt("LendingPool", config.pool, user);

    console.log("Depositing 1 ETH Collateral...");

    const tx = await pool.depositCollateral({ value: ethers.parseEther("1.0") });
    await tx.wait();

    console.log("Collateral Deposited!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
