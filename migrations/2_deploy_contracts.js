var Election = artifacts.require("./Auction.sol");

module.exports = function(deployer) {
  deployer.deploy(Election);
};
