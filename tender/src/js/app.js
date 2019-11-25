App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function () {
    return App.initWeb3();
  },

  initWeb3: function () {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;  
      web3 = new Web3(web3.currentProvider);
      
    } else
    {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function () {
    $.getJSON("Discount.json", function (discount) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Discount = TruffleContract(discount);
      // Connect provider to interact with contract
      App.contracts.Discount.setProvider(App.web3Provider);

      return App.render();
    });
  },

  render: function () {
    var discountInstance;


    // Load account data

    web3.eth.getCoinbase(function (err, account) {
      alert(account);
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

      App.contracts.Discount.deployed().then(function (instance) {
        discountInstance = instance;
        return discountInstance.couponCount();
      }).then(function (size) {
        alert(size);
      })
    

      },


 
  fun3: function () {
    v1=$("#bidAmtHash").val();
    alert(v1);
    App.contracts.Discount.deployed().then(function(instance){
      d=instance;
      return d.makeBid(v1,{from:web3.eth.accounts[0],gas:200000})
    })


  },


fun4: function()
{
  v1=$("#non").val();
  v2=$("#bid").val();
App.contracts.Discount.deployed().then(function(instance){
      e=instance;
      return e.generateHash(v1,v2,{from:web3.eth.accounts[0],gas:600000});
    }).then(function(a){
      alert(a);
    })
},



  fun5: function () {
    

    App.contracts.Discount.deployed().then(function(instance){
      d=instance;
      return d.getPhase()
    }).then(function(s){
      alert(s);
    })


  },

  fun6: function () {
    v1=$("#isOwner").val();
    App.contracts.Discount.deployed().then(function(instance){
      d=instance;
      return d.isOwner(v1)
    }).then(function(s){
      alert(s);
    })


  },

  fun8: function () {
    App.contracts.Discount.deployed().then(function(instance){
      d=instance;
      return d.endRevelation({from:App.account,gas:200000});
    }).then(function(){
    
    })


  },

  fun9: function () {
    App.contracts.Discount.deployed().then(function(instance){
      d=instance;
      return d.getResults()
    }).then(function(r){
    alert(r[0]);
    })


  },


  fun7: function () {
    v1=$("#nonce").val();
    v2=$("#amt").val();
    
    App.contracts.Discount.deployed().then(function(instance){
      d=instance;
      alert("");
      return d.revealBid(v1,v2,{from:web3.eth.accounts[0],gas:600000});
    })


  },

  fun4: function() {
    
    alert("");
    v1=$("#desc").val();
    v2=$("#biddingDuration").val();
    v3=$("#revelationDuration").val();
    v4=$("#depositAmount").val();

     App.contracts.Discount.deployed().then(function(instance){
       d=instance;
       return d.makeTender(v1,v2,v3,v4,{from:App.account,gas:600000})
     })
  }
};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              