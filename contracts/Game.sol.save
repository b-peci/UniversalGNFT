// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract Games {
    struct Game {
        string name;
        address payable owner;
        uint256[] tokens;
    }
    mapping(string => Game) GameStorage;
    mapping(address => string[]) OwnerGames;


    modifier _isGameNameTaken(string memory _name) {
        require(
            GameStorage[_name].owner == address(0),
            "This name is already taken, please choose another one"
        );
        _;
    }
    modifier _onlyOwner(string memory _name) {
        require(
            GameStorage[_name].owner == msg.sender,
            "Only the owner of the game can create an NFT"
        );
        _;
    }

    function getOwnersGame() public view returns (string[] memory) {
        return OwnerGames[msg.sender];
    }
    function getGameTokens(string memory _name) external view returns(uint256[] memory) {
        return GameStorage[_name].tokens;
    }

    function createGame(
        string memory _name
    ) external _isGameNameTaken(_name) {
        uint256[] memory _tokens;
        Game memory newGame = Game({
            name: _name,
            owner: payable(msg.sender),
            tokens: _tokens
        });
        GameStorage[_name] = newGame;
        OwnerGames[msg.sender].push(_name);
    }

    function addGameTokenToGame(
        string memory _gameName,
        uint256 tokenId
    ) public _onlyOwner(_gameName) {
        GameStorage[_gameName].tokens.push(tokenId);
    }
}
