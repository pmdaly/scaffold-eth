const { ethers } = require("hardhat");
const { expect } = require("chai");


const toEther = (amount) => {return ethers.utils.parseEther(amount)};

describe("Staker Dapp", function () {
    describe("Staker Contract", function () {
        before(async function () {
            this.signers = await ethers.getSigners();
            this.alice = this.signers[0];
            this.bob = this.signers[1];
            this.charlie = this.signers[2];
            this.StakerFactory = await ethers.getContractFactory("Staker");
        });
        beforeEach( async function () {
            this.staker = await this.StakerFactory.deploy(this.alice.address);
        });
        it("stake(): can add funds", async function () {
            expect(await this.staker.stakedAmounts(this.alice.address)).to.equal(0);
            await this.staker.stake({'from': this.alice.address, 'value': toEther("0.5")});
            expect(await this.staker.stakedAmounts(this.alice.address)).to.equal(toEther("0.5"));
        })
        it("withdraw(): can't withdraw before deadline", async function () {
            await this.staker.stakedAmounts(this.alice.address);
            await expect(this.staker.withdraw({'from': this.alice.address})).to.be.revertedWith("must wait until the deadline has passed");
        });
    });
    describe("External Contract", function () {
    });
});
