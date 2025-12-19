// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// estate management with confidentiality
contract EstateManager is ZamaEthereumConfig {
    struct Estate {
        address owner;
        string description;
        euint32 totalValue;      // encrypted
        address[] assets;
        bool active;
    }
    
    struct Transaction {
        address from;
        address to;
        euint32 amount;
        string description;
        uint256 timestamp;
    }
    
    mapping(address => Estate) public estates;
    mapping(address => Transaction[]) public transactions;
    
    event EstateCreated(address indexed owner);
    event TransactionRecorded(address indexed estate, uint256 timestamp);
    
    function createEstate(
        string memory description,
        euint32 encryptedValue
    ) external {
        estates[msg.sender] = Estate({
            owner: msg.sender,
            description: description,
            totalValue: encryptedValue,
            assets: new address[](0),
            active: true
        });
        emit EstateCreated(msg.sender);
    }
    
    function recordTransaction(
        address to,
        euint32 encryptedAmount,
        string memory description
    ) external {
        Estate storage estate = estates[msg.sender];
        require(estate.active, "Estate not active");
        
        transactions[msg.sender].push(Transaction({
            from: msg.sender,
            to: to,
            amount: encryptedAmount,
            description: description,
            timestamp: block.timestamp
        }));
        
        emit TransactionRecorded(msg.sender, block.timestamp);
    }
    
    function getTransactionCount() external view returns (uint256) {
        return transactions[msg.sender].length;
    }
}

