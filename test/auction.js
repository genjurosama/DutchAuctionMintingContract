const { expect, assert } = require('chai');
const { ethers } = require("hardhat")

describe("Auction Smart Contract Tests", function() {

    this.beforeEach(async function() {
        // This is executed before each test
        const Auction = await ethers.getContractFactory("Auction");
        const [account1,account2] = await ethers.getSigners();
        auction = await Auction.deploy("Auction", "auction",20,30,[account1.address, account2.address], [60, 40]);

    })


    it("shouldn't set base URI as non owner", async function() {
        try {
            [account1,account2] = await ethers.getSigners();
            expect(await auction.balanceOf(account1.address)).to.equal(0);
            await auction.connect(account2).setBaseURI("ipfs://QmPdoAtcJc9uXtWYLSkerWEpX5fMnsktHP8XajQEPAqdu6/");
            assert.fail("not the owner")
        }catch (err) {
            assert.include(err.message, "VM Exceptio", "The error message should contain 'VM Exceptio'");
        }
        
    })


    it("try to mint auction before allowed time ", async function() {
            try{
                const auctionStartTime = new Date();
                auctionStartTime.setMinutes(auctionStartTime.getMinutes() + 30);
                const [account1,account2] = await ethers.getSigners();
                await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
                await auction.connect(account1).auctionMint(3);
                assert.fail("not started yet")
            }catch(err){

            }

        
    })

    it("try to mint auction after allowed time and test first step of auction ", async function() {
       
            const auctionStartTime = new Date();
            auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 20);
            const [account1,account2] = await ethers.getSigners();
            await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
            const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
            expect(price).to.equal('0.95');
            await auction.connect(account1).auctionMint(1,{
                value: ethers.utils.parseEther("1.0")});    
            
            token = await auction.connect(account1).tokenOfOwnerByIndex(account1.address,0);
            const totalSupply = await auction.connect(account1).totalSupply();    
            expect(totalSupply).to.equal(1);
        
    
})

it("try to mint auction after allowed time and test second step of auction ", async function() {
       
    const auctionStartTime = new Date();
    auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 40);
    const [account1,account2] = await ethers.getSigners();
    await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
    const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
    expect(price).to.equal('0.9');
    await auction.connect(account1).auctionMint(1,{
        value: ethers.utils.parseEther("1.0")});    
    

})


it("try to mint auction after allowed time and test 3rd step of auction ", async function() {
       
    const auctionStartTime = new Date();
    auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 60);
    const [account1,account2] = await ethers.getSigners();
    await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
    const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
    expect(price).to.equal('0.85');
    await auction.connect(account1).auctionMint(1,{
        value: ethers.utils.parseEther("1.0")});    
    


})

it("try to mint auction after allowed time and test last step of auction ", async function() {
       
    const auctionStartTime = new Date();
    auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 340);
    const [account1,account2] = await ethers.getSigners();
    await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
    const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
    expect(price).to.equal('0.15');
    await auction.connect(account1).auctionMint(1,{
        value: ethers.utils.parseEther("1.0")});    
    


})


it("try to mint auction after allowed time and test before last step of auction ", async function() {
       
    const auctionStartTime = new Date();
    auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 320);
    const [account1,account2] = await ethers.getSigners();
    await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
    const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
    expect(price).to.equal('0.2');
    await auction.connect(account1).auctionMint(1,{
        value: ethers.utils.parseEther("1.0")});    
    

})

it("try to mint over supply ", async function() {
    try {
        const auctionStartTime = new Date();
        auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 320);
        const [account1,account2] = await ethers.getSigners();
        await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
        const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
        expect(price).to.equal('0.2');
        await auction.connect(account1).auctionMint(50,{
            value: ethers.utils.parseEther("1000")});    
        const totalSupply = await auction.connect(account1).totalSupply();   
        assert.fail("exceed limit")
    } 
    catch(err) {
        assert.include(err.message, "You exceeded the remaining limit", "The error message should contain 'You exceeded the remaining limit'");
    }
 
})


it("try to full mint and withdraw money", async function() {
       
    const auctionStartTime = new Date();
    auctionStartTime.setMinutes(auctionStartTime.getMinutes() - 10);
    const [account1,account2] = await ethers.getSigners();
    await auction.connect(account1).setAuctionStartTime( Math.floor(auctionStartTime.getTime()/ 1000));
    const price = ethers.utils.formatEther(await auction.connect(account1).getPrice());
    expect(price).to.equal('1.0');
    await auction.connect(account1).auctionMint(30,{
        value: ethers.utils.parseEther("30")});
    const previousBalance = ethers.utils.formatEther(await account1.getBalance());
    shares = await auction.connect(account1).shares(account1.address);
    releasable = ethers.utils.formatEther(await auction.connect(account1).moneyDue(account1.address)); 
    await auction.connect(account1).withdrawMoney(account1.address); 
   
    
    expect(shares).to.equal(60);
    expect(releasable).to.equal('18.0');
    releasable = ethers.utils.formatEther(await auction.connect(account1).moneyDue(account1.address)); 
    expect(releasable).to.equal('0.0')
    const currentBalance = Number(ethers.utils.formatEther(await account1.getBalance())) - Number(previousBalance);
    expect(currentBalance).to.be.lte(18).and.gte(17);
    try {
        await auction.connect(account1).withdrawMoney(account1.address); 
        assert.fail();
    }catch(err){
        assert.include(err.message, "account is not due payment", "The error message should contain 'account is not due payment");
    }

})

    
})