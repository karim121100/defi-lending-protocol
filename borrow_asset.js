const { ethers } = require("hardhat");
const config = require("./lending_config.json");

async function main() {
    const [user] = await ethers.getSigners();
    const pool = await ethers.getContractAt("LendingPool", config.pool, user);
    const usdc = await ethers.getContractAt("MockUSDC", config.usdc, user);

    // 1 ETH = $2000. 80% LTV = Max $1600 borrow.
    const borrowAmount = ethers.parseEther("1500");

    console.log(`Borrowing 1500 USDC...`);

    const tx = await pool.borrow(borrowAmount);
    await tx.wait();

    const balance = await usdc.balanceOf(user.address);
    console.log(`Borrow Successful! User USDC Balance: ${ethers.formatEther(balance)}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
