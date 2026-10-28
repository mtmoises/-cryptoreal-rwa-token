// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CryptorealRWA is ERC20, Ownable, Pausable {
    uint256 public constant MAX_SUPPLY = 10000000 * 10**18;
    mapping(address => bool) public isKYCApproved;
    
    event AssetTokenized(address indexed investor, uint256 amount, string assetId);
    event KYCApproved(address indexed investor);

    constructor(uint256 initialSupply) ERC20("Cryptoreal RWA", "CRRWA") Ownable(msg.sender) {
        require(initialSupply <= MAX_SUPPLY, "Exceeds max supply");
        _mint(msg.sender, initialSupply * 10**18);
        isKYCApproved[msg.sender] = true;
    }

    function approveKYC(address investor) external onlyOwner {
        isKYCApproved[investor] = true;
        emit KYCApproved(investor);
    }

    function tokenizeAsset(address investor, uint256 amount, string memory assetId) external onlyOwner whenNotPaused {
        require(isKYCApproved[investor], "Not KYC approved");
        require(totalSupply() + amount * 10**18 <= MAX_SUPPLY, "Exceeds cap");
        _mint(investor, amount * 10**18);
        emit AssetTokenized(investor, amount, assetId);
    }

    function transfer(address to, uint256 value) public override whenNotPaused returns (bool) {
        require(isKYCApproved[to], "Recipient not KYC approved");
        return super.transfer(to, value);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}