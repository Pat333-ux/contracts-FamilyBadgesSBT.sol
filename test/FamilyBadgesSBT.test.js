const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FamilyBadgesSBT Contract", function () {
  let sbtContract, owner, recipient, attacker;

  beforeEach(async function () {
    [owner, recipient, attacker] = await ethers.getSigners();

    const FamilyBadgesSBT = await ethers.getContractFactory("FamilyBadgesSBT");
    sbtContract = await FamilyBadgesSBT.deploy("https://api.munisible.org/metadata/", owner.address);
    await sbtContract.waitForDeployment();
  });

  it("Should allow the owner to issue a Soulbound badge", async function () {
    const category = "Family Guardian";
    await sbtContract.issueBadge(recipient.address, category);

    expect(await sbtContract.ownerOf(1)).to.equal(recipient.address);
    expect(await sbtContract.badgeCategories(1)).to.equal(category);
    expect(await sbtContract.locked(1)).to.be.true;
  });

  it("Should REJECT token transfers between users (Soulbound)", async function () {
    await sbtContract.issueBadge(recipient.address, "Task Force Leader");

    // Attempt transfer from recipient to attacker
    await expect(
      sbtContract.connect(recipient).transferFrom(recipient.address, attacker.address, 1)
    ).to.be.revertedWith("SBT: Soulbound tokens cannot be transferred");
  });
});
