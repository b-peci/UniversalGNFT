// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./GNFTBasicToken.sol";

/// @title Contract for creating game NFT-s
/// @author Bekim Peci
/// @notice This smart contract is the main functionality for creating NFT-s and re-using them throughout
/// different games that use this contract

contract Token is ERC721("GameNFT", "G-NFT") {
    event TokenSwaped(address from, address to);
    event TokenCreated(uint256 tokenId);
    enum TokenType {
        Fire,
        Water,
        Earth,
        Wind
    }
    // The req. that need to be met in order to trade an  NFT
    struct TokenCreationRequirements {
        uint256 FireReq;
        uint256 WaterReq;
        uint256 EarthReq;
        uint256 WindReq;
    }
    // ! Having both canBeSwapped and isLocked might be redundant 
    struct TokenData {
        uint256 tokenId;
        string tokenUri;
        string tokenFunctionality;
        bool isLocked;
        TokenCreationRequirements requirements;
        bool canBeSwaped;
        uint256[] lockedTokenIds;
    }
    address basicTokenCreationContract;
    uint256 s_tokenCounter;
    BasicGNFT BasicGNFTContract;
    mapping(address => uint256[]) addressTokens;

    constructor(address tokenCreationContract) {
        BasicGNFTContract = BasicGNFT(tokenCreationContract);
    }

    mapping(uint256 => TokenData) GNFTData;

    modifier isOwner(uint256 tokenId) {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only the owner is allowed to do that"
        );
        _;
    }

    modifier satisfiesFireRequirements(
        uint256[] memory tokenIds,
        uint256 tokenToSwapForId
    ) {
        require(
            checkIfFireTokenRequiremtnsAreMet(
                getFireTokenIds(tokenIds),
                tokenToSwapForId
            ),
            "Fire requirements not met"
        );
        _;
    }

    modifier satisfiesWaterRequirements(
        uint256[] memory tokenIds,
        uint256 tokenToSwapForId
    ) {
        require(
            checkIfWaterRequirementsAreMet(
                getWaterTokenIds(tokenIds),
                tokenToSwapForId
            ),
            "Water requirements not met"
        );
        _;
    }

    modifier satisfiesEarthRequirements(
        uint256[] memory tokenIds,
        uint256 tokenToSwapForId
    ) {
        require(
            checkIfEarthRequirementsAreMet(
                getEarthTokenIds(tokenIds),
                tokenToSwapForId
            ),
            "Earth requirements not met"
        );
        _;
    }

    modifier satisfiesWindRequirements(
        uint256[] memory tokenIds,
        uint256 tokenToSwapForId
    ) {
        require(
            checkIfWindRequirementsAreMet(
                getWindTokenIds(tokenIds),
                tokenToSwapForId
            ),
            "Wind requirements not met"
        );
        _;
    }

    modifier canTokenBeSwaped(uint256 tokenId) {
        require(GNFTData[tokenId].canBeSwaped, "Token cannot be swaped");
        require(!GNFTData[tokenId].isLocked, "Token is locked, cannot swap");
        _;
    }

    // Data modification functionality
    function createGameNFT(
        string memory _tokenURI,
        TokenCreationRequirements memory _tokenReq,
        string memory _tokenFunctionality
    ) public {
        uint256 nftTokenId = s_tokenCounter;
        _safeMint(msg.sender, nftTokenId);
        GNFTData[nftTokenId].requirements = _tokenReq;
        GNFTData[nftTokenId].canBeSwaped = true;
        GNFTData[nftTokenId].tokenFunctionality = _tokenFunctionality;
        setTokenURI(_tokenURI, nftTokenId);
        GNFTData[nftTokenId].tokenId = nftTokenId;
        s_tokenCounter = s_tokenCounter + 1;
        addressTokens[msg.sender].push(nftTokenId);
        emit TokenCreated(nftTokenId);
    }

    function swapTokens(
        uint256[] memory basicTokenIds,
        uint256 tokenToSwapForId
    )
        public
        satisfiesFireRequirements(basicTokenIds, tokenToSwapForId)
        satisfiesWaterRequirements(basicTokenIds, tokenToSwapForId)
        satisfiesEarthRequirements(basicTokenIds, tokenToSwapForId)
        satisfiesWindRequirements(basicTokenIds, tokenToSwapForId)
        canTokenBeSwaped(tokenToSwapForId)
    {
        BasicGNFTContract.lockTokens(basicTokenIds, msg.sender);
        _safeTransfer(
            ownerOf(tokenToSwapForId),
            msg.sender,
            tokenToSwapForId,
            ""
        );
        GNFTData[tokenToSwapForId].lockedTokenIds = basicTokenIds;
        addressTokens[msg.sender].push(tokenToSwapForId);
        lockToken(tokenToSwapForId);
    }

    //May not be needed anymore
    function removeTokenFromAddress(address currentOwner, uint256 tokenId) private{
        for(uint256 i = 0; i < addressTokens[msg.sender].length; i++) {
            if(addressTokens[currentOwner][i] == tokenId) {
                delete addressTokens[msg.sender][i];
                break;
            }
        }
    }
    // Burning is probably wrong here or at least not needed
    function disassembleToken(uint256 tokenId) public isOwner(tokenId) {
        removeTokenFromAddress(msg.sender, tokenId);
        unlockToken(tokenId);
        _burn(tokenId);
        BasicGNFTContract.unlockTokens(GNFTData[tokenId].lockedTokenIds);
    }

    function lockToken(uint256 tokenId) public isOwner(tokenId) {
        GNFTData[tokenId].canBeSwaped = false;
        GNFTData[tokenId].isLocked = true;
    }

    // same note as lockToken(uint256 tokenId)
    function unlockToken(uint256 tokenId) public isOwner(tokenId) {
        GNFTData[tokenId].isLocked = false;
        GNFTData[tokenId].canBeSwaped = true;
    }

    function setTokenURI(
        string memory _tokenURI,
        uint256 tokenId
    ) public isOwner(tokenId) {
        _requireMinted(tokenId);
        GNFTData[tokenId].tokenUri = _tokenURI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return GNFTData[tokenId].tokenUri;
    }

    function isTokenLocked(uint256 tokenId) public view returns (bool) {
        return GNFTData[tokenId].isLocked;
    }

    function getTokenData(
        uint256 tokenId
    ) public view returns (TokenData memory) {
        return GNFTData[tokenId];
    }

    function getHolderTokenIds() public view returns (uint256[] memory) {
        return addressTokens[msg.sender];
    }

    function checkIfFireTokenRequiremtnsAreMet(
        uint256 fireTokenCount,
        uint256 tokenToSwapForId
    ) private view returns (bool) {
        return
            fireTokenCount == GNFTData[tokenToSwapForId].requirements.FireReq;
    }

    function checkIfWaterRequirementsAreMet(
        uint256 waterTokenCount,
        uint256 tokenToSwapForId
    ) private view returns (bool) {
        return
            waterTokenCount == GNFTData[tokenToSwapForId].requirements.WaterReq;
    }

    function checkIfEarthRequirementsAreMet(
        uint256 earthTokenCount,
        uint256 tokenToSwapForId
    ) private view returns (bool) {
        return
            earthTokenCount == GNFTData[tokenToSwapForId].requirements.EarthReq;
    }

    function checkIfWindRequirementsAreMet(
        uint256 windTokenCount,
        uint256 tokenToSwapForId
    ) private view returns (bool) {
        return
            windTokenCount == GNFTData[tokenToSwapForId].requirements.WindReq;
    }

    function getFireTokenIds(
        uint256[] memory basicTokenIds
    ) private view returns (uint256 fireTokenCount) {
        for (uint i = 0; i < basicTokenIds.length; i++) {
            if (BasicGNFTContract.isTokenFireType(basicTokenIds[i])) {
                fireTokenCount++;
            }
        }
    }

    function getWaterTokenIds(
        uint256[] memory basicTokenIds
    ) private view returns (uint256 tokenCount) {
        for (uint i = 0; i < basicTokenIds.length; i++) {
            if (BasicGNFTContract.isTokenWaterType(basicTokenIds[i])) {
                tokenCount++;
            }
        }
    }

    function getEarthTokenIds(
        uint256[] memory basicTokenIds
    ) private view returns (uint256 tokenCount) {
        for (uint i = 0; i < basicTokenIds.length; i++) {
            if (BasicGNFTContract.isTokenEarthType(basicTokenIds[i])) {
                tokenCount++;
            }
        }
    }

    function getWindTokenIds(
        uint256[] memory basicTokenIds
    ) private view returns (uint256 tokenCount) {
        for (uint i = 0; i < basicTokenIds.length; i++) {
            if (BasicGNFTContract.isTokenWindType(basicTokenIds[i])) {
                tokenCount++;
            }
        }
    }
}
