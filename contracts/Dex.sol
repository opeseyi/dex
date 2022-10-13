// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DexV1 {
    using SafeMath for *;

    address[] public tokens;

    // bool public isApproved;

    constructor(address[] memory _tokens) {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address index = _tokens[i];
            require(index != address(0), "Constructor: Invalid Address");
            tokens.push(index);
        }
    }

    function getUserTokenBalance(address _token) public view returns (uint256) {
        require(_token != address(0), "User Balance: Invalid Address");
        bool token = _tokenCanBeSwap(_token);
        require(token == true, "User Balance: Token is not allowed");

        uint256 amountOfTokens = IERC20(_token).balanceOf(msg.sender);

        return amountOfTokens;
    }

    //   x    y
    function ethToToken(uint256 ethInput, address _tokenY) public payable returns (uint256) {
        uint256 totalEth = address(this).balance + ethInput;
        uint256 tokenY = IERC20(_tokenY).totalSupply();

        uint256 num = (tokenY.mul(997).mul(totalEth)).div(1000);
        uint256 simpl = (997.mul(totalEth)).div(1000); //simpl=> Random var name
        uint256 den = address(this).balance.add(simpl);
        uint256 yPriceChange = num / den;

        uint256 amount = tokenY.sub(yPriceChange);

        (bool success, ) = address(this).call{value: ethInput}("");
        require(success, "EthTOToke: Transfer Failed");
        bool isSuccessful = IERC20(_tokenY).transfer(msg.sender, amount);
        require(isSuccessful, "EthToToken: Transfer Failed to consumer");
        return amount;
    }

    function swapTokenAtoTokenB(
        address tokenToSwapA,
        address tokenToSwapB,
        uint256 amountToswap
    ) public returns (uint256) {
        require(tokenToSwapA != address(0), "Swap: Invalid token A address");
        require(tokenToSwapB != address(0), "Swap: Invalid token B address");
        require(amountToswap > 0, "Swap: Amount is invalid or too low");
        require(
            amountToswap < IERC20(tokenToSwapA).allowance(msg.sender, address(this)),
            "Swap: Amount is geater than Allowed"
        );

        // approveContract(tokenToSwapA, amountToswap);
        // require(isApproved, 'Swap: Not approved from the token');

        uint256 userTokenAmount = getUserTokenBalance(tokenToSwapA);
        require(userTokenAmount > 0, "Swap: Insufficien token");

        bool _tokenA = _tokenCanBeSwap(tokenToSwapA);
        require(_tokenA == true, "Swap: Token is not Allowed");
        bool _tokenB = _tokenCanBeSwap(tokenToSwapB);
        require(_tokenB == true, "Swap: Token is not Allowed");

        bool isSuccessful = IERC20(tokenToSwapA).transferFrom(
            msg.sender,
            address(this),
            amountToswap
        );
        require(isSuccessful, "Swap: Transfer of Failed to contract");
        uint256 amount = _getPrice(tokenToSwapA, tokenToSwapB, amountToswap);
        bool success = IERC20(tokenToSwapB).transfer(msg.sender, amount);
        require(success, "SWAP: Transfer Not successful to consumer");

        return amount;
    }

    function _getPrice(
        address _x,
        address _y,
        uint256 _amount
    ) public view returns (uint256) {
        uint256 x = (IERC20(_x).balanceOf(address(this))).sub(_amount);
        uint256 xWithBalance = x.add(_amount);
        uint256 y = IERC20(_y).balanceOf(address(this));
        uint256 totalTokenInContract = x * y;
        // uint256 amount = 997.div(1000);

        uint256 num = totalTokenInContract;
        uint256 den = xWithBalance;
        uint256 division = num.div(den);
        uint256 gettinY = y - division; // Note Transfer division to contract
        uint256 yWithCharges = gettinY.mul(3).div(1000);

        uint256 tokenY = gettinY - yWithCharges;

        return tokenY;
    }

    function _tokenCanBeSwap(address token) private view returns (bool) {
        require(token != address(0), "Helper[Token Can Be Swap]: Invalid Address");
        bool isEqual = false;
        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; i++) {
            address tokenAddress = tokens[i];
            address index = tokenAddress;
            if (index == token) {
                isEqual = true;
            }
        }
        return isEqual;
    }
}
