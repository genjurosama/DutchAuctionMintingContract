const { expect, assert } = require('chai');
const { ethers } = require("hardhat")

describe("Artwork Smart Contract Tests", function() {

    this.beforeEach(async function() {
        // This is executed before each test
        const Piradex = await ethers.getContractFactory("PiraDex");
        piradex = await Piradex.deploy("PiraDex", "Ahooy");
        const Gold = await ethers.getContractFactory("Gold");
        gold = await Gold.deploy();
    })

    it("NFT is minted successfully", async function() {
        [account1,account2] = await ethers.getSigners();
        expect(await piradex.balanceOf(account1.address)).to.equal(0);
        
        await piradex.connect(account1).setBaseURI("ipfs://QmPdoAtcJc9uXtWYLSkerWEpX5fMnsktHP8XajQEPAqdu6/");
        const mintTx = await piradex.connect(account1).mint();
        expect(await piradex.balanceOf(account1.address)).to.equal(1);
        expect(await piradex.tokenURI(0)).to.equal("ipfs://QmPdoAtcJc9uXtWYLSkerWEpX5fMnsktHP8XajQEPAqdu6/0.json");

    })


    it("shouldn't set base URI as non owner", async function() {
        try {
            [account1,account2] = await ethers.getSigners();
            expect(await piradex.balanceOf(account1.address)).to.equal(0);
            await piradex.connect(account2).setBaseURI("ipfs://QmPdoAtcJc9uXtWYLSkerWEpX5fMnsktHP8XajQEPAqdu6/");
            assert.fail("not the owner")
        }catch (err) {
            assert.include(err.message, "VM Exceptio", "The error message should contain 'VM Exceptio'");
        }
        
    })

    it("NFT is staked successfully", async function(){
        [account1] = await ethers.getSigners();

        expect(await piradex.balanceOf(account1.address)).to.equal(0);
        
        const tx = await piradex.connect(account1).setBaseURI("ipfs://QmPdoAtcJc9uXtWYLSkerWEpX5fMnsktHP8XajQEPAqdu6/");
        let mintTx = await piradex.connect(account1).mint();
        mintTx = await piradex.connect(account1).mint();
        expect(await piradex.balanceOf(account1.address)).to.equal(2);
        await piradex.connect(account1).stake(0);
        expect(await piradex.balanceOf(account1.address)).to.equal(1);
        await piradex.connect(account1).unstake(0);
        expect(await piradex.balanceOf(account1.address)).to.equal(2);

        
    })


    it("spawn new boss and hit him", async function(){
        [account1] = await ethers.getSigners();
        expect(await piradex.balanceOf(account1.address)).to.equal(0);
        
      
        
        await piradex.connect(account1).spawnNewBoss();
        let bossHpOld = await piradex.getBossHp();
        expect(bossHpOld).to.be.greaterThan(0);
        let mintTx = await piradex.connect(account1).mint();
        mintTx = await piradex.connect(account1).mint();
        expect(await piradex.balanceOf(account1.address)).to.equal(2);
        await piradex.connect(account1).hitBoss();
        let bossHpNew = await piradex.getBossHp();
        expect(bossHpNew).to.be.lte(bossHpOld);
 
        
    })

    it("should stake pirates",async function(){
        [account1,account2] = await ethers.getSigners();

        expect(await piradex.balanceOf(account1.address)).to.equal(0);
        
        const tx = await piradex.connect(account1).setBaseURI("ipfs://QmPdoAtcJc9uXtWYLSkerWEpX5fMnsktHP8XajQEPAqdu6/");
        let mintTx = await piradex.connect(account1).mint();
        mintTx = await piradex.connect(account1).mint();
        await piradex.connect(account2).mint();
        expect(await piradex.balanceOf(account1.address)).to.equal(2);
        console.log('piradex addy:',piradex.address)
        await gold.connect(account1).setPiraDexAdress(piradex.address);
        await piradex.setApprovalForAll(gold.address,true);
        await gold.connect(account1).stakeByIds([0,1]);
        expect(await piradex.balanceOf(account1.address)).to.equal(0);
        const stakedTokens = await gold.getTokensStaked(account1.address);
        console.log("staked tokens:",stakedTokens)

    })

    
})