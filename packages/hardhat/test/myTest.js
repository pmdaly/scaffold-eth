const { ethers } = require("hardhat");
const { expect } = require("chai");


const toEther = (amount) => {return ethers.utils.parseEther(amount)};

describe("Staker Contract", function () {
    before(async function () {
        this.signers = await ethers.getSigners();
        this.alice = this.signers[0];
        this.bob = this.signers[1];
        this.charlie = this.signers[2];
        this.owner = this.signers[3];
        this.ExternalFactory = await ethers.getContractFactory("ExampleExternalContract");
        this.StakerFactory = await ethers.getContractFactory("Staker");
    });
    beforeEach( async function () {
        this.extenalContract = await this.ExternalFactory.deploy();
        this.staker = await this.StakerFactory.deploy(this.owner.address);
    });
    it("stake(): can add funds", async function () {
        expect(await this.staker.getStakedAmount(this.alice.address)).to.equal(0);
        await this.staker.stake({'from': this.alice.address, 'value': toEther("0.5")});
        expect(await this.staker.getStakedAmount(this.alice.address)).to.equal(toEther("0.5"));
    })
    it("withdraw(): can't withdraw before deadline", async function () {
        await this.staker.stake({'from': this.alice.address, 'value': toEther("0.5")});
        const amount = toEther("0.5");
        await expect(this.staker.withdraw(amount, {'from': this.alice.address})).to.be.revertedWith(
            "must wait until the deadline has passed");
    });
    it("withdraw(): can withraw after the deadline but threshold not met", async function () {
        const stakeAmount = toEther("0.5");
        const walletBalanceBefore = await this.alice.getBalance();
        await this.staker.stake({'from': this.alice.address, 'value': stakeAmount});
        await ethers.provider.send("evm_increaseTime", [30])
        await this.staker.withdraw(stakeAmount, {'from': this.alice.address});
        const walletBalanceAfter = await this.alice.getBalance();
        expect(walletBalanceBefore.sub(stakeAmount)).to.equal(walletBalanceAfter);
    });
    it("withdraw(): can't withdraw after the deadline but threshold met", async function () {
        //await this.staker.stake({'from': this.alice.address, 'value': toEther("1.5")});
        //await ethers.provider.send("evm_increaseTime", [31])
        //await this.staker.execute();
        //await expect(this.staker.withdraw({'from': this.alice.address})).to.be.revertedWith('minimum threshold met, cannot withdraw');
    });
});
