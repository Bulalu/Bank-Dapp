from brownie import AceBank, config, network
from scripts.helpful_scripts import get_account


def deploy_ace_bank():
    account = get_account()
    ace_bank = AceBank.deploy(
        config["networks"][network.show_active()]["vault"],
        config["networks"][network.show_active()]["fee"],
        {"from": account},
        publish_source = config["networks"][network.show_active()]["verify"],
    )
    
    print("ACE Bank deployed!")
    return ace_bank

def main():
    deploy_ace_bank()