// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IOracle {
    function getEthPrice() external view returns (uint256);
}

contract LendingPool is Ownable, ReentrancyGuard {
    IERC20 public usdcToken;
    IOracle public oracle;

    uint256 public constant LTV = 80; // 80% Loan to Value
    uint256 public totalBorrowed;

    struct Account {
        uint256 collateralBalance; // In Wei (ETH)
        uint256 borrowBalance;     // In USDC units
    }

    mapping(address => Account) public accounts;

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    constructor(address _usdc, address _oracle) Ownable(msg.sender) {
        usdcToken = IERC20(_usdc);
        oracle = IOracle(_oracle);
    }

    // 1. Supply Collateral (ETH)
    function depositCollateral() external payable {
        require(msg.value > 0, "Amount 0");
        accounts[msg.sender].collateralBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 2. Borrow USDC against ETH
    function borrow(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount 0");
        require(usdcToken.balanceOf(address(this)) >= amount, "Insufficient liquidity");

        uint256 ethPrice = oracle.getEthPrice(); // e.g. 2000 USDC
        uint256 collateralValue = (accounts[msg.sender].collateralBalance * ethPrice) / 1e18;
        
        // Max borrow = Collateral Value * 80%
        uint256 maxBorrow = (collateralValue * LTV) / 100;
        uint256 currentDebt = accounts[msg.sender].borrowBalance;

        require(currentDebt + amount <= maxBorrow, "Health factor too low");

        accounts[msg.sender].borrowBalance += amount;
        totalBorrowed += amount;

        usdcToken.transfer(msg.sender, amount);
        emit Borrow(msg.sender, amount);
    }

    // 3. Repay Loan
    function repay(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount 0");
        require(accounts[msg.sender].borrowBalance >= amount, "Overpayment");

        usdcToken.transferFrom(msg.sender, address(this), amount);
        
        accounts[msg.sender].borrowBalance -= amount;
        totalBorrowed -= amount;
        
        emit Repay(msg.sender, amount);
    }

    // View: Check max borrowable for a user
    function getAccountInfo(address user) external view returns (uint256 collateral, uint256 debt, uint256 maxBorrow) {
        collateral = accounts[user].collateralBalance;
        debt = accounts[user].borrowBalance;
        
        uint256 ethPrice = oracle.getEthPrice();
        uint256 collateralValue = (collateral * ethPrice) / 1e18;
        maxBorrow = (collateralValue * LTV) / 100;
    }
}
