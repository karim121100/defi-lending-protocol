const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with:", deployer.address);

    // 1. Deploy Mock USDC
    const USDC = await ethers.getContractFactory("MockUSDC");
    const usdc = await USDC.deploy();
    await usdc.waitForDeployment();
    const usdcAddr = await usdc.getAddress();

    // 2. Deploy Oracle
    const Oracle = await ethers.getContractFactory("MockOracle");
    const oracle = await Oracle.deploy();
    await oracle.waitForDeployment();
    const oracleAddr = await oracle.getAddress();

    // 3. Deploy Pool
    const Pool = await ethers.getContractFactory("LendingPool");
    const pool = await Pool.deploy(usdcAddr, oracleAddr);
    await pool.waitForDeployment();
    const poolAddr = await pool.getAddress();

    console.log(`Lending Pool Deployed: ${poolAddr}`);

    // Fund the pool with USDC so users can borrow
    await usdc.transfer(poolAddr, ethers.parseEther("100000")); // Supply 100k USDC
    console.log("Pool funded with liquidity.");

    // Save config
    const config = { pool: poolAddr, usdc: usdcAddr, oracle: oracleAddr };
    fs.writeFileSync("lending_config.json", JSON.stringify(config));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
