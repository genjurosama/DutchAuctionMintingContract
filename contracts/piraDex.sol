// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract PiraDex is ERC721, Ownable, ERC721Burnable, ERC721Pausable{
    uint256 public tokenCounter;
    mapping (uint256 => string) private _tokenURIs;
    address withdrawAddress;
    string baseTokenURI;
    mapping(uint256 => address) public ownedTokens;
    mapping(uint256 => address) public staked;
    mapping(address => uint256) private stakedFromTS;
    mapping(address => uint256) public tokensHeldCount;
    uint256 public bossHp;
    

    constructor(string memory name, string memory symbol) ERC721(name,symbol) {
        tokenCounter = 0;
    }

    function mint() public {
        _safeMint(msg.sender, tokenCounter);
        ownedTokens[tokenCounter] = msg.sender;
        tokensHeldCount[msg.sender]++;
        console.log('minted successfuly token uri',tokenURI(tokenCounter));
        tokenCounter++;
    }
    

    function setWithdrawAddress(address _withdrawAddress) public onlyOwner {
        withdrawAddress = _withdrawAddress;
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Pausable) {
        //require(from == address(0), "Err: token is SOUL BOUND");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function stake(uint256 tokenId) external {
        require(ownedTokens[tokenId] == msg.sender, "You don't own this tokenId");
        _transfer(msg.sender, address(this), tokenId);
        stakedFromTS[msg.sender] = block.timestamp;
        staked[tokenId] = msg.sender;
        console.log("staked successfuly");
    }

    function unstake(uint256 tokenId) external {
        require(ownedTokens[tokenId] == msg.sender, "You don't own this tokenId");
        require(staked[tokenId] == msg.sender, "You haven't staked this token");
        _transfer(address(this), msg.sender, tokenId);
        delete staked[tokenId];
        console.log('deleted successfuly');
    }

    function spawnNewBoss() public onlyOwner {
        bossHp = createRandom(10)+1;
    }

    function hitBoss() public {
        require(tokensHeldCount[msg.sender] >0,"you don't own any token to play");
        uint256 damage = createRandom(3);
        bossHp -= damage;
        console.log("Boss took ",Strings.toString(damage));
    
    }

    function getCurrentBossHp() public view returns(uint) {
        return bossHp;
    }

    function createRandom(uint number) internal view returns(uint){
        return uint(blockhash(block.number-1)) % number;
    }

    function getBossHp() public view returns (uint){
        console.log("boss hp is:",bossHp);
        return bossHp;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return bytes(baseTokenURI).length > 0 ? string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId),".json")) : "";
    }

    



/*
    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 rewards = staked[msg.sender] * secondsStaked / 3.154e7; // 1:1 per year
        _mint(msg.sender,rewards);
        stakedFromTS[msg.sender] = block.timestamp;
    }
*/    

}