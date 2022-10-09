// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract DexV1 {
    using SafeMath for *;

    address[] public tokens;

    constructor(address[] memory _tokens) {
        for (uint256 i; i < _tokens.length; i++) {
            address index = _tokens[i];
            require(index != address(0), 'Constructor: Invalid Address');
            tokens.push(index);
        }
    }

    function approveContract(address _token, uint256 amount) public returns (bool) {
        require(amount > 0, "Approve Contract: Enter 'Amount' greater than zero");
        bool allowed = IERC20(_token).approve(address(this), amount);
        return allowed;
    }

    function getUserTokenBalance(address _token) public view returns (uint256) {
        require(_token != address(0), 'User Balance: Invalid Address');
        bool token = _tokenCanBeSwap(_token);
        require(token == true, 'User Balance: Token is not allowed');

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

        (bool success, ) = address(this).call{value: ethInput}('');
        require(success, 'EthTOToke: Transfer Failed');
        IERC20(_tokenY).transfer(msg.sender, amount);
        return amount;
    }

    function swapTokenAtoTokenB(
        address tokenToSwapA,
        address tokenToSwapB,
        uint256 amountToswap
    ) public returns (uint256) {
        require(tokenToSwapA != address(0), 'Swap: Invalid token A address');
        require(tokenToSwapB != address(0), 'Swap: Invalid token B address');
        require(amountToswap > 0, 'Swap: Amount is invalid or too low');
        require(
            approveContract(tokenToSwapA, amountToswap) == true,
            'Swap: Not approved from the token'
        );

        uint256 userTokenAmount = getUserTokenBalance(tokenToSwapA);
        require(userTokenAmount > 0, 'Swap: Insufficien token');

        bool _tokenA = _tokenCanBeSwap(tokenToSwapA);
        require(_tokenA == true, 'Swap: Token is not Allowed');
        bool _tokenB = _tokenCanBeSwap(tokenToSwapB);
        require(_tokenB == true, 'Swap: Token is not Allowed');

        IERC20(tokenToSwapA).transferFrom(msg.sender, address(this), amountToswap);
        uint256 amount = _getPrice(tokenToSwapA, tokenToSwapB, amountToswap);
        IERC20(tokenToSwapB).transfer(msg.sender, amount);

        return amount;
    }

    function _getPrice(
        address _x,
        address _y,
        uint256 _amount
    ) public view returns (uint256) {
        uint256 x = IERC20(_x).totalSupply();
        uint256 y = IERC20(_y).totalSupply();
        // uint256 amount = 997.div(1000);

        uint256 totalTokenX = x + _amount;

        uint256 num = (y.mul(997).mul(totalTokenX)).div(1000);
        uint256 simpl = (997.mul(totalTokenX)).div(1000); //simpl=> Random var name
        uint256 den = x.add(simpl);
        uint256 yPriceChange = num / den;

        uint256 amount = y.sub(yPriceChange);

        return amount;
    }

    function _tokenCanBeSwap(address token) private view returns (bool) {
        require(token != address(0), 'Helper[Token Can Be Swap]: Invalid Address');
        bool isEqual;
        for (uint256 i; i < tokens.length; i++) {
            address index = tokens[1];
            if (index == token) {
                isEqual = true;
            }
        }
        return isEqual;
    }
}
