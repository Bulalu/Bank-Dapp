from brownie import accounts, AceBank
import pytest




@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass

def test_deposit_and_withdraw():
    account = accounts[0]
    vault = accounts[5]
    acebank = AceBank.deploy({'from':account})
    amount = "20 ether"
    #deposit
    print(vault.balance())
    tx = acebank.deposit({"from":account, "value":amount})
    print(acebank.balance())
    assert acebank.balance() == amount
    tx.wait(1)
    #withdraw
    acebank.withdraw(amount, {"from":account})
    assert acebank.balance() == 0
    print(acebank.balance())
    print(vault.balance())
    # print("fee", acebank.calculateFee(amount))