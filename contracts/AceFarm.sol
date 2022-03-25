pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./token/AceToken.sol";


contract AceFarm {

    // userAddress => stakingBalance
    mapping(address => uint256) public stakingBalance;
    // userAddress => isStaking boolean
    mapping(address => bool) public isStaking;
    // userAddress => timeStamp
    mapping(address => uint256) public startTime;
    // userAddress => aceBalance
    mapping(address => uint256) public aceBalance;

    string public name = "AceFarm";
    
    IERC20 public daiToken; //staking token
    AceToken public aceToken;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed to, uint256 amount);
    event YieldWithdraw(address indexed from, uint256 amount);

    constructor(
        IERC20 _daiToken,
        AceToken _aceToken
    ) {
        daiToken = _daiToken;
        aceToken = _aceToken;
    }

    /// Core function shell
    // stake() public {};
    // unstake() public {};
    // withdrawYield() public {};
    function stake(uint256 amount) public {
        require(amount > 0 && daiToken.balanceOf(msg.sender) >= amount, "Not enough amount to stake");

        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            aceBalance[msg.sender] += toTransfer;
        }

        daiToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);

    }

    function unstake(uint256 amount) public {
        require(amount > 0 && stakingBalance[msg.sender] >= amount, "Nothing to unstake");

        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balTransfer;
        daiToken.transfer(msg.sender, balTransfer);
        aceBalance[msg.sender] += yieldTransfer;

        if(stakingBalance[msg.sender] == 0) {
            isStaking[msg.sender] = false;
        }

        emit Unstake(msg.sender, balTransfer);


    }

    function calculateYieldTime(address user) public view returns(uint256) {
       
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10 ** 18;
        uint256 rate = 86400;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate) / 10 ** 18;
        return rawYield;
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(toTransfer > 0 || aceBalance[msg.sender] > 0, "Nothing to withdraw");

        if (aceBalance[msg.sender] != 0) {
            uint256 oldBalance = aceBalance[msg.sender];
            aceBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        aceToken.mint(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);

    }


}