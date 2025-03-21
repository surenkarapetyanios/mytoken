const { ethers } = require("hardhat");
const { expect } = require("chai");
const { parseUnits } = require("ethers");

describe("MyToken Full Coverage", function () {
  let token, owner, addr1, addr2;

  beforeEach(async function () {
    const Token = await ethers.getContractFactory("MyToken");
    const initialSupply = parseUnits("1000", 18);
    token = await Token.deploy("MyToken", "MTK", initialSupply);
    await token.waitForDeployment();

    [owner, addr1, addr2] = await ethers.getSigners();
  });

  it("should return correct totalSupply", async function () {
    const supply = await token.totalSupply();
    expect(supply).to.equal(parseUnits("1000", 18));
  });

  it("should return correct owner", async function () {
    const contractOwner = await token.owner();
    expect(contractOwner).to.equal(owner.address);
  });

  it("should return correct balanceOf", async function () {
    const balance = await token.balanceOf(owner.address);
    expect(balance).to.equal(parseUnits("1000", 18));
  });

  it("should allow transfers", async function () {
    await token.transfer(addr1.address, parseUnits("100", 18));
    const balance = await token.balanceOf(addr1.address);
    expect(balance).to.equal(parseUnits("100", 18));
  });

  it("should approve spender correctly", async function () {
    await token.approve(addr1.address, parseUnits("200", 18));
    const allowance = await token.allowance(owner.address, addr1.address);
    expect(allowance).to.equal(parseUnits("200", 18));
  });

  it("should increase allowance", async function () {
    await token.increaseAllowance(addr1.address, parseUnits("50", 18));
    const allowance = await token.allowance(owner.address, addr1.address);
    expect(allowance).to.equal(parseUnits("50", 18));
  });

  it("should decrease allowance", async function () {
    await token.increaseAllowance(addr1.address, parseUnits("100", 18));
    await token.decreaseAllowance(addr1.address, parseUnits("40", 18));
    const allowance = await token.allowance(owner.address, addr1.address);
    expect(allowance).to.equal(parseUnits("60", 18));
  });

  it("should allow transferFrom with approval", async function () {
    await token.approve(addr1.address, parseUnits("100", 18));
    const tokenFromAddr1 = token.connect(addr1);
    await tokenFromAddr1.transferFrom(owner.address, addr2.address, parseUnits("80", 18));
    const balance = await token.balanceOf(addr2.address);
    expect(balance).to.equal(parseUnits("80", 18));
  });

  it("should mint only by owner", async function () {
    await token.mint(owner.address, parseUnits("500", 18));
    const balance = await token.balanceOf(owner.address);
    expect(balance).to.equal(parseUnits("1500", 18));
  });

  it("should revert mint if not owner", async function () {
    const tokenFromAddr1 = token.connect(addr1);
    await expect(
      tokenFromAddr1.mint(addr1.address, parseUnits("1000", 18))
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should transfer ownership", async function () {
    await token.transferOwnership(addr1.address);
    const newOwner = await token.owner();
    expect(newOwner).to.equal(addr1.address);
  });

  it("should renounce ownership", async function () {
    await token.renounceOwnership();
    const currentOwner = await token.owner();
    expect(currentOwner).to.equal("0x0000000000000000000000000000000000000000");
  });
});