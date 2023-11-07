// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "hardhat/console.sol";
 
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenID;
    Counters.Counter private _itemsold;

    uint256 listigprice = 0.0010 ether;

    address payable owner;

    mapping (uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint256 tokenid;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;

     }


     event idMarketItemCreated(
        uint256 indexed tokenid,
        address seller,
        address owner,
        uint256 price,
        bool sold
     );

     modifier ONLYOwner() {
      require(
         msg.sender ==owner,
         "owner of the market can change the price of listing nft"
      );
      _;
      
     }

     constructor() ERC721("mong token", "nocoin"){
      owner == payable(msg.sender);
     }
    
    function updatePricelisting(uint256 _listingPrice) public ONLYOwner{
      listigprice = _listingPrice;
    }


    function getListingPrice() public view returns(uint256){
      return listigprice;
    }


   //  now create NFT ToKEn Function

   function CreateToken(string memory tokenURI,uint256 price)
    public 
    payable 
    returns(uint256)
    {
      _tokenID.increment();

      uint256 newTOkenID =_tokenID.current();

      _mint(msg.sender,newTOkenID);
      
      _setTokenURI(newTOkenID,tokenURI);

      CreateMarketItem(newTOkenID,price);

      return newTOkenID;

   }

// now create nft market items

   function CreateMarketItem(uint256 tokenid ,uint256 price) private {
      
      require(price > 0, "price should more then 0");
      
      require(msg.value == listigprice, "price must be at least minimum listig price");
      


      idMarketItem[tokenid] = MarketItem(
         tokenid,
         payable(msg.sender),
         payable(address(this)),
         price,
         false
      );

      _transfer(msg.sender, address(this), tokenid);

      emit idMarketItemCreated(
         tokenid,
         msg.sender,
         address(this),
         price,
         false
      );

 }


       // now create marketsell

   function CreatesellingMarket(uint256 tokenid) public payable{
      uint256 price = idMarketItem[tokenid].price;

      require(
         msg.value == price,
           "please pay the ether to complete the order to complete the purchase" 
      );

      idMarketItem[tokenid].owner = payable(msg.sender);
      idMarketItem[tokenid].sold = true;
      idMarketItem[tokenid].owner = payable(address(0));

      _itemsold.increment();
      
      _transfer(address(this),msg.sender,tokenid);
      
      // collecting commition as market owner
      payable(owner).transfer(listigprice);
      payable(idMarketItem[tokenid].seller).transfer(msg.value);

   }


   // function for resell token

   function resellNFT_token(uint256 tokenid, uint256 price) public payable{
      require(
         idMarketItem[tokenid].owner ==  msg.sender, 
         "only nft owner can perform perform this operation"
         );

      require(
         msg.value == listigprice, 
         "price must be equal to listing price"
         );

      idMarketItem[tokenid].sold = false;
      idMarketItem[tokenid].price = price;
      idMarketItem[tokenid].seller = payable(msg.sender);
      idMarketItem[tokenid].owner = payable(address(this));

      _itemsold.decrement();

      _transfer(msg.sender,address(this),tokenid);


   }


  

   // now getting the data unsold NFTs

   function fetchMarketNFTDetails() public view returns(MarketItem[] memory){

      uint256 itemCount = _tokenID.current();
      uint256 unsoldNFtCount = _tokenID.current() - _itemsold.current();
      uint256 currentIndex = 0;

      MarketItem[] memory items = new MarketItem[](unsoldNFtCount);

      for (uint256 i = 0; i < itemCount; i++ ) {
         if (idMarketItem[i + 1].owner == address(this)){
            uint256 currentid = i + 1;

            MarketItem storage currentItem = idMarketItem[currentid];
            items[currentIndex] = currentItem;
            currentIndex += 1;  
         }
      }
      return items;
   }


   // puchase NFTs
   function fechmyNFT()public view returns(MarketItem[] memory){
      uint256 totalCount = _tokenID.current();
      uint256 itemCount =0;
      uint256 currentIndex = 0;

      for (uint256 i = 0; i < totalCount; i++){
         if(idMarketItem[i + 1].owner == msg.sender){
            itemCount += 1;
         }
      }

      MarketItem[] memory items =new MarketItem[](itemCount);
      for(uint256 i = 0; i < totalCount; i++) {
           
           if(idMarketItem[i + 1].owner == msg.sender){
            uint256 currentid = i+ 1;
            MarketItem storage currentItem = idMarketItem[currentid];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
         

 
      }
      return items;

   }


   // single user NFTs

   function fechListedNFT() public view returns (MarketItem[] memory){
      uint256 totalCount = _tokenID.current();
      uint256 itemCount = 0;
      uint256 currentIndex = 0;

      for (uint256 i = 0; i < totalCount; i++){
         if(idMarketItem[i+1].seller == msg.sender){
            itemCount += 1;
         }
      }
      MarketItem[] memory items =new MarketItem[](itemCount);
      for(uint256 i = 0; i < totalCount; i++){
         uint256 currentid = i + 1;
         MarketItem storage currentItem = idMarketItem[currentid];
         items[currentIndex] = currentItem;
         currentIndex += 1; 
      }
      return items; 
   }
}