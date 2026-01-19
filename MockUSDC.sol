// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {
        // Mint 10M USDC to deployer
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }

    // Helper to faucet tokens for testing
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
