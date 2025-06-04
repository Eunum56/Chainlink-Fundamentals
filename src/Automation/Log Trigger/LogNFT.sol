// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title LogNFT
 * @author Mohammed Muzammil
 * @notice A simple ERC721 NFT contract which emits TransferTriggered log on any type of NFT transfer.
 * @dev Only from/actual owner of the NFT/Token will get rewarded after a successfull transfer.
 */
contract LogNFT is ERC721, Ownable {
    // ERRORS
    error LogNFT__InvalidAddress();
    error LogNFT__MaxSupplyExceeds();

    // EVENTS
    event TransferTriggered(address indexed from, address indexed to, uint256 indexed tokenId);

    // STATE VARIABLES
    uint256 private s_tokenCounter;
    uint256 public constant MAX_SUPPLY = 1000;

    // FUNCTIONS
    constructor() ERC721("LogNFT", "LNFT") Ownable(msg.sender) {
        s_tokenCounter = 0;
    }

    // EXTERNAL FUNCTIONS
    /**
     * @notice Only owner can mints the NFT
     * @param _to The address to receive the NFT
     */
    function mint(address _to) external onlyOwner {
        if (_to == address(0)) {
            revert LogNFT__InvalidAddress();
        }
        if (s_tokenCounter >= MAX_SUPPLY) {
            revert LogNFT__MaxSupplyExceeds();
        }
        _safeMint(_to, s_tokenCounter);
        s_tokenCounter++;
    }

    // PUBLIC FUNCTIONS
    /**
     * @notice Transfers a token and emits TransferTriggered.
     * @param from The address of current NFT owner
     * @param to The address of receiver
     * @param tokenId ID of the NFT
     * @notice From address will get rewarded
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        super.transferFrom(from, to, tokenId);
        emit TransferTriggered(from, to, tokenId);
    }

    /**
     * @notice Transfers a token and emits TransferTriggered.
     * @param from The address of current NFT owner
     * @param to The address of receiver
     * @param tokenId ID of the NFT
     * @notice From address will get rewarded
     */
    function safeTransferFromWithoutData(address from, address to, uint256 tokenId) public {
        super.safeTransferFrom(from, to, tokenId);
        emit TransferTriggered(from, to, tokenId);
    }

    /**
     * @notice Transfers a token and emits TransferTriggered.
     * @param from The address of current NFT owner
     * @param to The address of receiver
     * @param tokenId ID of the NFT
     * @param data Extra data
     */
    function safeTransferFromWithData(address from, address to, uint256 tokenId, bytes memory data) public {
        super.safeTransferFrom(from, to, tokenId, data);
        emit TransferTriggered(from, to, tokenId);
    }


    // GETTERS
    function getTokenCounter() external view returns(uint256) {
        return s_tokenCounter;
    }
}
