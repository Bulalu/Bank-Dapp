from brownie import accounts, AceBank
from scripts.deploy_bank import deploy_ace_bank
import pytest
import brownie
from scripts.helpful_scripts import get_account, ZERO_ADDRESS


@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


@pytest.fixture(scope="module", autouse=True)

def test_deposit_and_withdraw():
    account = accounts[0]
    vault = accounts[5]
    fee  = 500
    acebank = deploy_ace_bank()
    
    amount = "20 ether"
    tx = acebank.updateAce(vault, fee, {"from": get_account()})
    #deposit
    print("before",vault.balance())
    acebank.deposit({"from":account, "value":amount})

    assert account.balance -= amount
    tx.wait(1)
    #withdraw
    acebank.withdraw(amount, {"from":account})
    assert acebank.balance() == 0
    
    print("after",vault.balance())
    

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

    tx = ace_bank.updateAce(vault, fee, {"from": owner})
    assert vault == tx.events["AceUpdated"]["vault"]
    assert fee == tx.events["AceUpdated"]["_fee"]
    
    
