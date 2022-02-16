pragma solidity ^0.8.6;

contract AceBank {
    // deposit
    // withdraw
    // loans
    // security
    mapping(address => uint256) public balances;
    //5 percent
    uint256 private constant MULTIPLIER_PRECISION = 1e18;
    uint256 private constant PERCENTAGE_PRECISION = 10000;
    uint256 private constant  FEE = 500;
    address  private Vault = 0x807c47A89F720fe4Ee9b8343c286Fc886f43191b; //account no 5

    function deposit() public payable returns(uint256){
        balances[msg.sender] += msg.value;
        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @return The balance remaining for the user
    function withdraw(uint256 _amount) public returns(uint256) {
        // require: only those who have deposited
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        uint fees = calculateFee(_amount);
        uint256 required_amount = _amount - fees;
        payable(msg.sender).transfer(required_amount);
        payable(Vault).transfer(fees);
        
        return balances[msg.sender];
        //think on how to send token, rn the contract has no token
        // maybe make it payable ??
        //also think of adding an a destination address to withdraw to (security reasons?)
        // create a vault of which some fee will be allocated to while withdrawing
    }

    /// @notice calculate the fee
    /// @return the amount after fee has been deducted

    function calculateFee(uint256 _amount) private returns(uint256) {
        //Do You really need this function, this math could just be doneup there
        uint256 newAmount = _amount * (FEE) / PERCENTAGE_PRECISION  ;
        return newAmount;
    }
    // think of a function to change the fee
    //think of a function to changes the vault

    function balance() external view returns(uint256) {
        return balances[msg.sender];
    }
}