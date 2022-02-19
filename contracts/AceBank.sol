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
        // Do users need a role before withdrawing? 
        require(balances[msg.sender] >= _amount, "withdraw: Insufficient balance");
        balances[msg.sender] -= _amount;
        uint fees = _amount * (fee) / PERCENTAGE_PRECISION ;
        uint256 required_amount = _amount - fees;
        payable(msg.sender).transfer(required_amount);
        payable(Vault).transfer(fees);
        
        return balances[msg.sender];
        
        //also think of adding an a destination address to withdraw to (security reasons?)
    }

    
    function updateAce(address _address, uint256 _fee) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "updateAce: Admin Permissions Required");
        require(_address != address(0) && _address != address(this), "Invalid Vault address");
        require(_fee < 10000); // dev: feePercentage greater than 10000 (100.00%)
        Vault = _address;
        fee = _fee;
        emit AceUpdated(_address, _fee);
    }

    function grantAdminRole(address _address) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "grantAdminRole: Admin Permissions Required");
        require(_address != address(0) && _address != address(this), "Invalid address");
        _grantRole(DEFAULT_ADMIN_ROLE, _address);
    }
    

    // think of loan functionalities
    // interest rates 
    // pause functionalities
    // emergency exit
    


    function checkAdminRole(address _address) public view returns(bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    
}