// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Auction is ERC721Enumerable, Ownable, PaymentSplitter {
   
    using Counters for Counters.Counter;
    Counters.Counter counter;
    uint32 public immutable maxPerWallet;
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
        uint32 _maxPerWallet,
        uint32 _collectionSize,
        address[] memory _payees,
        uint256[] memory _shares

    ) ERC721(name,symbol) PaymentSplitter(_payees, _shares) payable {
        maxPerWallet = _maxPerWallet;
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
       for (uint i=0;i< quantity ; i++) {
            counter.increment();
            _safeMint(msg.sender, counter.current());
        }
       
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
   
    function moneyDue(address account) public  view returns (uint256) {
        return super.releasable(account);
    }
    

    function withdrawMoney(address payable account) public {
        release(account);
    }


     function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    _requireMinted(tokenId);

    return bytes(baseTokenURI).length > 0 ? string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId),".json")) : "";
}


}