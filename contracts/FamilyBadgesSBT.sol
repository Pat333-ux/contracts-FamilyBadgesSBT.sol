// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC5192 {
    event Locked(uint256 tokenId);
    function locked(uint256 tokenId) external view returns (bool);
}

/**
 * @title FamilyBadgesSBT
 * @dev Non-transferable Soulbound Token (SBT) for Munisible Task Force & Family First credentials.
 * Implements ERC-5192 standard for soulbound tokens.
 */
contract FamilyBadgesSBT is ERC721, IERC5192, Ownable {
    using Strings for uint256;

    uint256 private _nextTokenId;
    string private _baseTokenURI;

    // Mapping tokenId => Badge Category
    mapping(uint256 => string) public badgeCategories;

    // Events
    event BadgeIssued(address indexed recipient, uint256 indexed tokenId, string category);

    constructor(
        string memory baseURI, 
        address initialOwner
    ) ERC721("Munisible Task Force Soulbound Badge", "MTF-SBT") Ownable(initialOwner) {
        _baseTokenURI = baseURI;
    }

    /**
     * @notice Issues a Soulbound Badge to a task force or family member.
     * @param to Address of the recipient
     * @param category Badge category (e.g., "Family Guardian", "Self-Mastery Tier 1", "Task Force Leader")
     */
    function issueBadge(address to, string memory category) external onlyOwner returns (uint256) {
        uint256 tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);
        badgeCategories[tokenId] = category;

        emit Locked(tokenId);
        emit BadgeIssued(to, tokenId, category);

        return tokenId;
    }

    /**
     * @notice ERC-5192 Soulbound interface implementation. All tokens are permanently locked.
     */
    function locked(uint256 tokenId) external view override returns (bool) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return true;
    }

    /**
     * @dev Override transfers to prevent Soulbound tokens from being transferred or sold.
     */
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == 0) and burning (to == 0), block all user-to-user transfers
        if (from != address(0) && to != address(0)) {
            revert("SBT: Soulbound tokens cannot be transferred");
        }

        return super._update(to, tokenId, auth);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }
}
