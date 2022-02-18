pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";
contract AceBank is AccessControl {
    // deposit
    // withdraw
    // loans
    // security
    mapping(address => uint256) public balances;
    //5 percent
    bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
    uint256 private constant MULTIPLIER_PRECISION = 1e18;
    uint256 private constant PERCENTAGE_PRECISION = 10000;
    uint256 private fee;
    address  private Vault; // 0x807c47A89F720fe4Ee9b8343c286Fc886f43191b; //account no 5
    
    event Deposited(address indexed depositer, uint256 amount_deposited);
    event AceUpdated(address indexed vault, uint256 _fee);
    constructor(address _vault, uint256 _fee) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        fee = _fee;
        Vault = _vault;
    }
    function deposit() public payable returns(uint256){
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @return The balance remaining for the user
    function withdraw(uint256 _amount) public returns(uint256) {
        // require: only those who have deposited
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        uint fees = _amount * (fee) / PERCENTAGE_PRECISION ;
        uint256 required_amount = _amount - fees;
        payable(msg.sender).transfer(required_amount);
        payable(Vault).transfer(fees);
        
        return balances[msg.sender];
        //think on how to send token, rn the contract has no token
        // maybe make it payable ??
        //also think of adding an a destination address to withdraw to (security reasons?)
        // create a vault of which some fee will be allocated to while withdrawing
    }

    
    function updateAce(address _address, uint256 _fee) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "updateAce: Admin Permissions Required");
        require(_address != address(0) && _address != address(this), "Invalid Vault address");
        require(_fee < 10000); // dev: feePercentage greater than 10000 (100.00%)
        Vault = _address;
        fee = _fee;
        emit AceUpdated(_address, _fee);
    }
    // think of a function to change the fee
    //think of a function to changes the vault
    


    function checkAdminRole(address _address) public view returns(bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    
}