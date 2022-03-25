pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
* @title Ace Bank:
*     
*        
*                    ██╗░█████╗░░█████╗░███╗░░██╗██╗░█████╗░  ░█████╗░░█████╗░███████╗
*                    ██║██╔══██╗██╔══██╗████╗░██║██║██╔══██╗  ██╔══██╗██╔══██╗██╔════╝
*                    ██║██║░░╚═╝██║░░██║██╔██╗██║██║██║░░╚═╝  ███████║██║░░╚═╝█████╗░░
*                    ██║██║░░██╗██║░░██║██║╚████║██║██║░░██╗  ██╔══██║██║░░██╗██╔══╝░░
*                    ██║╚█████╔╝╚█████╔╝██║░╚███║██║╚█████╔╝  ██║░░██║╚█████╔╝███████╗
*                    ╚═╝░╚════╝░░╚════╝░╚═╝░░╚══╝╚═╝░╚════╝░  ╚═╝░░╚═╝░╚════╝░╚══════╝

*/
contract AceBank is AccessControl {
    
    mapping(address => uint256) public balances;
    
    bytes32 public constant ACE_ROLE = keccak256("ACE_ROLE");
    uint256 private constant MULTIPLIER_PRECISION = 1e18;
    uint256 private constant PERCENTAGE_PRECISION = 10000;
    uint256 private fee;
    address payable private  vault; // 0x807c47A89F720fe4Ee9b8343c286Fc886f43191b; //account no 5
    
    event Deposited(address indexed depositer, uint256 amount_deposited);
    event AceUpdated(address indexed vault, uint256 _fee);
    event WithDrawn (address indexed withdrawer, uint256 amount);
    constructor(address  payable _vault, uint256 _fee) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        fee = _fee;
        vault = _vault;
    }
    function deposit() public payable returns(uint256){
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
        grantAceRole(msg.sender);
        return balances[msg.sender];

    }

    /// @notice Withdraw ether from bank
    /// @return The balance remaining for the user
    function withdraw(uint256 _amount) public returns(uint256) {
        require(checkAceRole(msg.sender), "You are not a member of the Ace Bank");
        require(balances[msg.sender] >= _amount, "withdraw: Insufficient balance");
        balances[msg.sender] -= _amount;
        uint fees = _amount * (fee) / PERCENTAGE_PRECISION ;
        uint256 required_amount = _amount - fees;
        (bool success,) = msg.sender.call{value:required_amount}("");
        (bool vault_success,) = vault.call{value:fees}("");
        require(success && vault_success, "Transaction Failed");

        
        return balances[msg.sender];
        
    }
    /// @notice Users must have the ACE role for them to withdraw funds
     function grantAceRole(address _address) private {
         _grantRole(ACE_ROLE, _address);
     }

     function revokeAceRole(address _address) private {
         _grantRole(ACE_ROLE, _address);
     }
    
    
    function updateAce(address  payable _address, uint256 _fee) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "updateAce: Admin Permissions Required");
        require(_address != address(0) && _address != address(this), "Invalid Vault address");
        require(_fee < 10000); // dev: feePercentage greater than 10000 (100.00%)
        vault = _address;
        fee = _fee;
        emit AceUpdated(_address, _fee);
    }

    function grantAdminRole(address _address) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "grantAdminRole: Admin Permissions Required");
        require(_address != address(0) && _address != address(this), "Invalid address");
        _grantRole(DEFAULT_ADMIN_ROLE, _address);
    }
    
    
    function checkAdminRole(address _address) public view returns(bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function checkAceRole(address _address) public view returns(bool) {
        return hasRole(ACE_ROLE, _address);
    }

    
}