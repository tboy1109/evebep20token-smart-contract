//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ClaimTrusterrasToken {
    address public owner;
    uint256 public balance;
    address tokenAddress = 0xf8e81D47203A594245E36C48e151709F0C19fBe8; // change this to the token address of the contract

    //mapping to whitelist users
    mapping(address => bool) whitelistedAddresses;

    event TransferSent(address _from, address _destAddr, uint256 _amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        balance += msg.value;
    }

    // Whitelist section

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier isWhitelisted(address _address) {
        require(
            whitelistedAddresses[_address],
            "Whitelist: You need to be whitelisted"
        );
        _;
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
        whitelistedAddresses[_addressToWhitelist] = true;
    }

    function verifyUser(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }

    function exampleFunction()
        public
        view
        isWhitelisted(msg.sender)
        returns (bool)
    {
        return (true);
    }

    // End whitelist section

    function getAllTokenBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    //function claimTST(IERC20 token, uint amount, address to) public {
    //require(msg.sender == to, "Not allowed");
    //uint erc20balance = token.balanceOf(address(this));
    //require(amount <= erc20balance, "Low Balance");
    //token.transfer(to, amount);
    //emit TransferSent(msg.sender, to , amount);
    //}

    // The address to must be the same as the registered Ethereum address with the username in MongoDB

    //code without the whitelist

    //function claimTST(IERC20 token, address to) public {
    //uint amount = 300; // hard coded
    //require(msg.sender == to, "Not allowed");
    //token.approve(msg.sender, amount);
    //token.transfer(to, amount);
    //emit TransferSent(msg.sender, to , amount);
    //}

    //code with the whitelist

    function checkBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(msg.sender));
    }

    // this claim function uses a whitelist

    function claimTSTWhitelist(IERC20 token, address _whitelistedAddress)
        public
    {
        uint256 amount = 300; // hard coded

        if (IERC20(tokenAddress).balanceOf(address(msg.sender)) >= 50000) {
            revert("You have claimed the maximum amount of tokens");
        }

        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];

        if (userIsWhitelisted == true) {
            token.approve(msg.sender, amount);
            token.transfer(_whitelistedAddress, amount);
            whitelistedAddresses[_whitelistedAddress] = false;    //remove the address from whitelist after claim
            emit TransferSent(msg.sender, _whitelistedAddress, amount);
        } else {
            revert("Claim is invalid");
        }

       
    }

    // this function uses no whitelist

    function claimTST(IERC20 token, address _address) public {
        uint256 amount = 300; // hard coded

        if (IERC20(tokenAddress).balanceOf(address(msg.sender)) >= 50000) {
            revert("You have claimed the maximum amount of tokens");
        }

        token.approve(msg.sender, amount);
        token.transfer(_address, amount);
        emit TransferSent(msg.sender, _address, amount);
    }
}
