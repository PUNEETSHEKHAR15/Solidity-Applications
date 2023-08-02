#Dutch Auction

Interfering the IERC721 transfer function from IERc721 contract

// from which address to which address and which nft(nftid)

interface IERC721 {
// from which address to which address and which nft(nftid)
function transferFrom(address \_from, address \_to, uint nftId) external;
}

\*\*Declaring the state variable

1.nft => this is the address which holds the nfts

2.nftId =>this will be the nft id which help to trade the particular nft from the list of the nft's holding by the address

3.seller=>address of the seller who deploys the contract

4.startingPrice => initial price of the nft at which auction begins

5.startAt=>time at which auction starts

6.expiresAt=> time at which aunction ends

7.discountRate=discount rate at which the price will decrease with time

8.DURATION=>time of the auction , when its live

uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

\*\*constructor Entry point of he contract =>initallizes some values , \_startingPrice,\_discountRate,\_nft,\_nftId

initallize the seller as payable to send the funds at which nft will be sold

startAt = block.timestamp;=> starting time

expiresAt = block.timestamp + DURATION;=>expiring time

require statment for checking price that is sent to buy nft more then cuurent price otherwise it displays the error

    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        require(
            _startingPrice >= _discountRate * DURATION,
            "staringPrice<discount"
        );
        nft = IERC721(_nft);
        nftId = _nftId;
    }

    getprice function is to fetch current price of the nft with decrease with time

     function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

\*\* buy function is to buy the registered nft

require that time should be less that expires time

after passing all the condiitons it will transfer nft from one owner contract address to buyer contract address

then refund the amount of money which buyer has payed while buying nft

at last delete or end the contract by selfDestruct by sending all ethers to seller

function buy() external payable {
require(block.timestamp < expiresAt, "Auction Ended ");
uint price = getPrice();
require(msg.value >= price, "Eth < price");
nft.transferFrom(seller, msg.sender, nftId);
uint refund = msg.value - price;
if (refund > 0) {
payable(msg.sender).transfer(refund);
}
selfdestruct(payable(seller));
}
