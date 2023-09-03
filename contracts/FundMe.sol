//SPDX-License-Identifier: MIT
//pragma
pragma solidity ^0.8.8;
//imports
import "./PriceConverter.sol";
//errors
error FundMe_NotOwner();

/**
 * @title A contract for crowd funding
 * @author Maheswar Reddy
 * @notice This is a sample funding project
 */
contract FundMe {
    //Type Declerations
    using PriceConverter for uint256;

    //State Variables
    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;
    mapping(address => uint256) private s_addressToAmountFunded;
    uint256 public constant minimumUsd = 50 * 1e18;
    address private immutable i_owner;

    //Modifiers

    modifier onlyOwner() {
        //require(msg.sender == owner,"sender is not owner");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }

    //constructor
    //receive function
    //fallback function
    //external
    //public
    //internal
    //private

    constructor(address priceFeedAdress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAdress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /** @notice This function funds this project
     *  @dev This implements pricefeed as library
     */

    function fund() public payable {
        //want to set minimum in usd
        require(
            msg.value.getConversionRate(s_priceFeed) > minimumUsd,
            "Didn't send enough amount"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset array
        s_funders = new address[](0);
        //withdraw funds
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        //withdraw funds
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
