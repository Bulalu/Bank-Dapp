pragma solidity ^0.8.6;

contract AceBank {
    // deposit
    // withdraw
    // loans
    // security
    mapping(address => uint256) public balances;

    function deposit(uint256 _amount) public {
        balances[msg.sender] += _amount;
    }
    
    function withdraw(uint256 _amount) public {
        // require: only those who have deposited
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        //think on how to send token, rn the contract has no token
        // maybe make it payable ??
        //also think of adding an a destination address to withdraw to (security reasons?)
        
    }
}