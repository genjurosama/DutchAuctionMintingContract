// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";


contract Auction is ERC721Enumerable, Ownable, PaymentSplitter{
   
    uint32 public immutable maxPerWallet;
    uint32 public immutable amountForTeam;
    uint32 public immutable amountForAuction;
    uint32 public immutable collectionSize;
    string baseTokenURI;
    
    struct SaleConfig {
        uint256 auctionSaleStartTime;
        uint256 publicSaleStartTime;
        uint64 mintlistPrice;
        uint64 publicPrice;
        uint32 publicSaleKey;
        uint32 auctionInitialPrice;
    }


    SaleConfig public saleConfig;

    mapping(address => uint256) public allowlist;

    uint256 public constant AUCTION_START_PRICE = 1 ether;
    uint256 public constant AUCTION_END_PRICE = 0.15 ether;
    uint256 public constant AUCTION_PRICE_CURVE_LENGTH = 340 minutes;
    uint256 public constant AUCTION_DROP_INTERVAL = 20 minutes;
    uint256 public constant AUCTION_DROP_PER_STEP = 0.05 ether;


    constructor(
        string memory name,
        string memory symbol, 
        uint32 _amountForTeam, 
        uint32 _amountforAuction,
        uint32 _maxPerWallet,
        uint32 _collectionSize,
        address[] memory _payees,
        uint256[] memory _shares

    ) ERC721(name,symbol) PaymentSplitter(_payees, _shares) payable {
        maxPerWallet = _maxPerWallet;
        amountForTeam = _amountForTeam;
        amountForAuction = _amountforAuction;
        collectionSize = _collectionSize;
    }

    modifier callerIsUser () {
        require(tx.origin == msg.sender,"The caller is another contract");
        _;
    }

    function auctionMint(uint32 quantity) public payable callerIsUser{
        uint32 auctionSaleStartTime = uint32(saleConfig.auctionSaleStartTime);
        require(auctionSaleStartTime != 0 && block.timestamp >= auctionSaleStartTime,
                "Auction hasn't started yet");
       require( totalSupply() + quantity <= collectionSize,"You exceeded the remaining limit");
       uint256 totalCost = getPrice() * quantity;
       _safeMint(msg.sender, quantity);
       refundIfOver(totalCost);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function getPrice() public view returns (uint256){
        if(block.timestamp < saleConfig.auctionSaleStartTime){
            return AUCTION_START_PRICE;
        }
        else if(block.timestamp >= saleConfig.auctionSaleStartTime + AUCTION_PRICE_CURVE_LENGTH){
            return AUCTION_END_PRICE;
        }
        else{
            uint256 steps = (block.timestamp - saleConfig.auctionSaleStartTime )/ AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (AUCTION_DROP_PER_STEP * steps);
        }
    }
    

    function setAuctionStartTime(uint256 auctionStartTime ) external onlyOwner{
        saleConfig.auctionSaleStartTime = auctionStartTime;
    }
   
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function moneyDue(address account) public  view returns (uint256) {
        return super.releasable(account);
    }
    

    function withdrawMoney(address payable account) public {
        release(account);
    }

}