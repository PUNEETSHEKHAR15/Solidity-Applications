//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NftMarketplace is ERC721URIStorage{
    address payable owner;

    /* using Counters contract to keep the count of nft 
    _tokenIds==> for keep id track 
    _itemSold=>>to keep sold nft track  
    */
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemSold;


// mention basic  deploying price of the nft  
    uint256 public listPrice = 0.01 ether;
    constuctor()ERC721("NFTMARKETPLACE","NFTM"){
        owner=payable(msg.sender);
    }

 /**thing needed to create new nft first is tokenid , owner, seller, price , isCurrentlyListed
  
  */
    struct ListToken  {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool isCurrentlyListed;
        
    }

    mapping (uint256 => ListToken) private idToListToken;

    // to increase the listing price of the NFT
    function  updateListingPrice(uint256 _listprice) public payable {
        require(owner==msg.sender,"only owner can change the lisitng price");
        listPrice=_listprice;
        
    } 
    // function to retrieve the token feature or ListToken(struct) associated with that token id 
    function LatestInfoOfListedToken() public view returns(ListenToken memory){
        uint256 currentTokenId = _tokenIds.current();
        return idToListToken[currentTokenId];
    } 

// get details of the listed token by tokenid 
    function getTokenIdInfo(uint tokenId) public view returns(ListenToken memory){
    return idToListToken[tokenId];
    }

    // get current token id 
    function getLastestTokenId() public view returns(uint256 ){
        return _tokenIds.current();
    }


/**
 * 5 important functions are 
 * createToken 
 * createListedToken
 * getAllNfts
 * getAllMyNFTs
 * exaecuteSale
 */
function createToken(string memory tokenURI, uint256 price)public payable returns(uint){
    require(msg.value==listPrice,"msg.value is less then listed price");
    require(price>0,"you have entered negative number")
    _tokenIds.increment();
    uint currentTokenId = _tokenIds.current();
    //1. _safeMint function
    _safeMint(msg.sender,currentTokenId); 
    //2. _setTokenURI 
    _setTokenURI(currentTokenId,tokenURI);
    createListedToken(currentTokenId,price)
    return currentTokenId;
}

function createListedToken(uint tokenId, uint price ) private {
    idToListToken[tokenId]=ListenToken(
        tokenId,
        payable(address(this)),
        payable(msg.sender);
        price,
        true,
    );
    _transfer(msg.sender,address(this),tokenId)
}

function getAllNfts() public view returns(ListenToken[] memory){
    uint nftCount= _tokenIds.current();
    ListenToken[] memory tokens= new ListenToken[](nftCount);
    uint currentIndex = 0;
    for (i=0;i<nftCount;i++){
        uint currentId=i+1;
        //currentItem hold the structure of ListedToken 
        ListedToken storage currentItem = idToListToken[currentId];
        tokens[currentIndex]=currentItem;
        currentIndex+=1;

    }
return tokens;
}
    function getAllMyNFTs()public view returns(ListedToken[] memory){
    uint totalCount = _tokenIds.cuurent();
    uint itemCount = 0;
    uint currentIndex =0 ;
  
 
  for(i=0;i<totalCount;i++){
    if(idToListToken[i+1].owner==msg.sender || idToListToken[i+1].seller==msg.sender){
    itemCount+=1;
  }
  }

  ListedToken[] memory items= new ListedToken[](itemCount)
  for(i=0;i<totalCount;i++){
     if(idToListToken[i+1].owner==msg.sender || idToListToken[i+1].seller==msg.sender){
        uint currentId = i+1;
        ListedToken storage currentItem= idToListToken[currentId];
        items[currentIndex]= currentItem;
        currentIndex+=1;
     }
     return items;
  }
}

function executeSale(uint tokenId) public payable{
    uint price = idToListToken[tokenId].price;
    require(msg.value == price,"user sended less eth")
    address seller = idToListToken[tokenId].seller;
    idToListToken[tokenId].isCurrentlyListed=true;
    // this step transfer the owner ship to buyers 
    idToListToken[tokenId].seller = payable(msg.sender);
    _transfer(address(this),msg.sender,tokenId);
    approve(address(this),tokenId);
    payable(owner).transfer(listPrice);
    payable(seller).transfer(msg.value);

} 
} 

