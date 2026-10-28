// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CryptorealRWA_V2 is ERC20, Ownable2Step, Pausable {
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18;

    mapping(address => bool) public isKYCApproved;
    mapping(bytes32 => address) public assetToInvestor;

    event AssetTokenized(address indexed investor, uint256 amount, bytes32 indexed assetId);
    event KYCApproved(address indexed investor);
    event KYCRevoked(address indexed investor);

    error ZeroAddress();
    error ZeroAmount();
    error NotKYC(address account);
    error ExceedsCap();
    error AssetAlreadyTokenized(bytes32 assetId);

    constructor(uint256 initialSupply)
        ERC20("Cryptoreal RWA", "CRRWA")
        Ownable(msg.sender)
    {
        uint256 amount = initialSupply * 10**18;
        if (amount > MAX_SUPPLY) revert ExceedsCap();

        isKYCApproved[msg.sender] = true;
        _mint(msg.sender, amount);
    }

    // ---------- KYC ----------

    function approveKYC(address investor) external onlyOwner {
        if (investor == address(0)) revert ZeroAddress();
        isKYCApproved[investor] = true;
        emit KYCApproved(investor);
    }

    function revokeKYC(address investor) external onlyOwner {
        isKYCApproved[investor] = false;
        emit KYCRevoked(investor);
    }

    // ---------- Tokenización CEI Perfecto ----------

    function tokenizeAsset(address investor, uint256 amount, bytes32 assetId)
        external
        onlyOwner
    {
        if (investor == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (assetToInvestor[assetId] != address(0)) revert AssetAlreadyTokenized(assetId);

        uint256 scaled = amount * 10**18;
        if (totalSupply() + scaled > MAX_SUPPLY) revert ExceedsCap();

        // EFFECT
        assetToInvestor[assetId] = investor;
        
        // INTERACTION
        _mint(investor, scaled);

        emit AssetTokenized(investor, amount, assetId);
    }

    // ---------- Hook central OZ v5 ----------

    function _update(address from, address to, uint256 value)
        internal
        override
        whenNotPaused
    {
        if (from != address(0) && !isKYCApproved[from]) revert NotKYC(from);
        if (to != address(0) && !isKYCApproved[to]) revert NotKYC(to);
        super._update(from, to, value);
    }

    // ---------- Admin ----------

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
