from brownie import accounts, AceBank
from scripts.deploy_bank import deploy_ace_bank
import pytest
import brownie
from scripts.helpful_scripts import get_account, ZERO_ADDRESS
from web3 import Web3

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


@pytest.fixture(scope="module", autouse=True)

def test_deposit_and_withdraw(): 
    vault = accounts[5]
    depositor = accounts[3]
    bob = accounts[4]
    fee  = 500
    amount = Web3.toWei(20, "ether")
    acebank = deploy_ace_bank()
    
    bank_balance_before_deposit = acebank.balance()
    
    depositer_balance_before_deposit = depositor.balance()
    print("Depositer balance before", depositer_balance_before_deposit)
    acebank.updateAce(vault, fee, {"from": get_account()})
    
    #deposit
    acebank.deposit({"from":depositor, "value":amount})
    bank_balance_after_deposit = bank_balance_before_deposit + amount
    depositer_balance_after_deposit = depositer_balance_before_deposit - amount
    
    assert acebank.balance() == bank_balance_after_deposit
    assert depositor.balance() == depositer_balance_after_deposit
    assert acebank.balances(depositor.address) == amount
    
    # #withdraw
    with brownie.reverts("withdraw: Insufficient balance"):
        acebank.withdraw(amount, {"from":bob})
    print("Depositer balance b4 withdrawing", depositor.balance()) 
    print(acebank.balances(depositor.address) == amount) 
    with brownie.reverts("withdraw: Insufficient balance"):
        acebank.withdraw(amount * 2, {"from":depositor})

    ace_balance_depositer = acebank.balances(depositor.address)
    vault_balance_before = vault.balance()
    
    acebank.withdraw(amount, {"from":depositor})
    assert acebank.balances(depositor.address) == ace_balance_depositer - amount
    #do math on fee and the amount to send
    # fee is 500 ie 5%
    to_vault = amount * (fee/10000)
    to_user = amount - to_vault
    
    assert vault.balance() == vault_balance_before + to_vault
    assert depositor.balance() == depositer_balance_after_deposit + to_user
    

def test_access_role():
    account = accounts[0]
    bob = accounts[2]
    vault = accounts[5]
    acebank = deploy_ace_bank()
    amount = "20 ether"
    assert acebank.checkAdminRole(account) == True
    assert acebank.checkAdminRole(bob) == False

def test_update_ace():
    vault = accounts[3]
    fee = 500 #5%
    owner = get_account()
    bob = accounts[2]

    ace_bank = deploy_ace_bank()
    print(ace_bank.checkAdminRole(bob))
    with brownie.reverts("updateAce: Admin Permissions Required"):
        ace_bank.updateAce(vault , fee, {"from": bob})

    with brownie.reverts("dev: feePercentage greater than 10000 (100.00%)"):
        ace_bank.updateAce(vault, 50000, {"from": owner})
    
    with brownie.reverts("Invalid Vault address"):
        ace_bank.updateAce(ZERO_ADDRESS, fee, {"from": owner})
    
    with brownie.reverts("Invalid Vault address"):
        ace_bank.updateAce(ace_bank.address, fee, {"from": owner})

    tx = ace_bank.updateAce(vault, fee, {"from": owner})
    assert vault == tx.events["AceUpdated"]["vault"]
    assert fee == tx.events["AceUpdated"]["_fee"]
    
def test_add_admin():
    owner = get_account()
    bob = accounts[1]
    ace_bank = deploy_ace_bank()

    with brownie.reverts("grantAdminRole: Admin Permissions Required"):
        ace_bank.grantAdminRole(bob, {"from": bob})
    
    with brownie.reverts("Invalid address"):
        ace_bank.grantAdminRole(ZERO_ADDRESS, {"from": owner})
    
    with brownie.reverts("Invalid address"):
        ace_bank.grantAdminRole(ace_bank.address, {"from": owner})
    
    ace_bank.grantAdminRole(bob, {"from": owner})
    assert ace_bank.checkAdminRole(bob) == True

