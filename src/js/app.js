App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    
    return App.initWeb3();
  },

  initWeb3: function() {
    
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    alert("");
    $.getJSON("Auction.json", function(coupon) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Auction = TruffleContract(coupon);
      // Connect provider to interact with contract
      App.contracts.Auction.setProvider(App.web3Provider);
      return App.render();
    });
  },


  render: function() {
    var CouponInstance;

    
    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });
    // Load contract data
    App.contracts.Auction.deployed().then(function(instance) {
    }).catch(function(error) {
      console.warn(error);
    });
  },

  fun3:function() {
    x1=$('#address').val();
    x2=$('#title').val();
    x3=$('#startprize').val();
    x4=$('#desc').val();
    var CouponInstace;
    alert("");
    App.contracts.Auction.deployed().then(function(instance){
      alert("");
      AuctionInstace=instance;
      return AuctionInstace.x(x2,x3,x4,{from: web3.eth.accounts[1], gas: 1000000});
    }).then(function(x){
      alert(x);
    })
  },

  fun4:function() {
    x1=$('#bidValue').val();
    App.contracts.Auction.deployed().then(function(instance){
      alert("");
      AuctionInstace=instance;
      return AuctionInstace.placeBid(x1);
    }).then(function(x){
      alert(x);
    })
  },

  fun5:function() {
    AuctionInstace;
    App.contracts.Auction.deployed().then(function(instance){
      alert("");
      AuctionInstace=instance;
      return AuctionInstace.finalizeAuction();
    }).then(function(x){
      alert(x);
      z=AuctionInstace.highestBidder();
      alert(z);
      $('#winner').html(z);
    })
  },

  fun6:function() {
    App.contracts.Auction.deployed().then(function(instance){
      AuctionInstace=instance;
      return AuctionInstace.highestBidder();
    }).then(function(x){
      alert(x);
    })
  }
};

$(function() {
  alert("123");
  $(window).load(function() {
    alert("123");
    App.init();
  });
});
