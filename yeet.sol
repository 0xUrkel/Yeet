// _____.___._________________________________ 
// \__  |   |\_   _____/\_   _____/\__    ___/ 
//  /   |   | |    __)_  |    __)_   |    |    
//  \____   | |        \ |        \  |    |    
//  / ______|/_______  //_______  /  |____|    
//  \/               \/         \/             
//Experimental VRT Token by 0xUrkel 2023

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// YEET Token Smart Contract with Virtual Reward Technology (VRT)
contract YEET is ERC20, Ownable {
    // Mapping to store each address's YEET token balance.
    mapping(address => uint) internal balances;

    // Mapping to check if an address is a YEET token holder.
    mapping(address => bool) internal isTokenHolder;

    // Total virtual amount of YEET taxed from transactions.
    uint totalTaxedAmount = 0;

    // Counter for the number of unique YEET token holders.
    uint totalUniqueUsers = 0;

    // Tax rate for transactions, initialized to 0% (can be updated by the owner).
    uint public taxPercentage = 0;

    // Address of the contract owner, set during contract deployment.
    address public contractOwner;

    // Constructor for setting initial state of the contract.
    constructor() ERC20("YEET", "YEET") {
        // Assign the contract deployer as the owner of the initial token supply.
        contractOwner = msg.sender;

        // Mint an initial supply of YEET tokens to the contract owner.
        _mint(contractOwner, 100000000000000000000000); // 100,000 YEET tokens

        // Initialize the number of unique users to 1 (the contract owner).
        totalUniqueUsers = 1;

        // Register the contract owner as a token holder.
        isTokenHolder[contractOwner] = true;
    }

    // Overridden balanceOf function to integrate VRT.
    function balanceOf(address account) public view override returns (uint) {
        // Returns the standard token balance plus a virtual share of the taxed amount.
        // This share is a conceptual reflection of the tax distributed among holders.
        return super.balanceOf(account) + (totalTaxedAmount / totalUniqueUsers);
    }
    
    // Overridden transfer function to include virtual tax calculation.
    function transfer(address _to, uint _value) public override returns (bool) {
        // Calculate the virtual tax amount based on the transaction value.
        uint taxAmount = _value * taxPercentage / 100;

        // Ensure the sender has enough balance, considering the virtual tax.
        require(balanceOf(msg.sender) >= _value, "Insufficient funds");

        // Verify the transfer amount exceeds the calculated tax amount.
        require(_value > taxAmount, "Transfer amount must be greater than the tax");

        // Determine the actual amount transferred after deducting the virtual tax.
        uint amountAfterTax = _value - taxAmount;

        // Execute the transfer of the amount after tax.
        super.transfer(_to, amountAfterTax);

        // If recipient is a new token holder, increment the total unique users count.
        if(!isTokenHolder[_to]) {
            isTokenHolder[_to] = true;
            totalUniqueUsers++;
        }

        // Accumulate the virtual taxed amount (not physically transferred or distributed).
        totalTaxedAmount += taxAmount;

        // Return true to indicate successful transfer completion.
        return true;
    }

    // Function to enable the contract owner to set a new tax rate.
    function setTaxRate(uint _newTaxPercentage) public onlyOwner {
        // Validate the new tax rate to be within the range of 0% to 100%.
        require(_newTaxPercentage >= 0 && _newTaxPercentage <= 100, "Invalid tax rate");

        // Update the tax rate as specified.
        taxPercentage = _newTaxPercentage;
    }
}
