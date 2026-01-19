const { ethers } = require("hardhat");
const config = require("./lending_config.json");

async function main() {
    const [user] = await ethers.getSigners();
    const pool = await ethers.getContractAt("LendingPool", config.pool, user);
    const usdc = await ethers.getContractAt("MockUSDC", config.usdc, user);

    const repayAmount = ethers.parseEther("1500");

    console.log("Approving Pool to take USDC...");
    await usdc.approve(config.pool, repayAmount);

    console.log("Repaying Loan...");
    const tx = await pool.repay(repayAmount);
    await tx.wait();

    console.log("Loan Repaid!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
