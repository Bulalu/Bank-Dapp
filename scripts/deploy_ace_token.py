from brownie import AceToken, config, network
from scripts.helpful_scripts import get_account, TENPOW18


NAME = "ACEBANK"
SYMBOL = "ACE"

INITIAL_SUPPLY = 1000000 * TENPOW18

def deploy_ace_token():
    account = get_account()
    ace_token = AceToken.deploy(
        NAME,
        SYMBOL,
        account,
        INITIAL_SUPPLY,
        {"from": account},
        publish_source = config["networks"][network.show_active()]["verify"],
    )
    
    
    print("ACE Bank deployed!", ace_token)
    return ace_token


def main():
    deploy_ace_token()