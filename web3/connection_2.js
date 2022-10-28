import {
    Contract,
    Provider
} from 'ethers-multicall';
import {
    ethers
} from 'ethers';

// import * as ierc20 from './ABIs/ierc20.json' // assert {type: 'json'};

// import WalletConnect from 'walletconnect/client';
"use strict";

// const Web3Modal = window.Web3Modal.default;
// const WalletConnectProvider = window.WalletConnectProvider.default;
// // const Fortmatic = window.Fortmatic;
// const evmChains = window.evmChains;



let ierc20;
// let tokenAddress = "0xEC5dCb5Dbf4B114C9d0F65BcCAb49EC54F6A0867";

let provider;
let accounts;
let account;
let signer;

// testnet
let USDTContractAddress = "0x337610d27c682E347C9cD60BD4b3b107C9d34dDd"
let BUSDContractAddress = "0x337610d27c682E347C9cD60BD4b3b107C9d34dDd"

// mainnet
// let USDTContractAddress = ""
// let BUSDContractAddress = ""



const ContractAddressFight = "0xAAEe32a89704306127304DC00787aAC0b7f1aEf3";
let FightNight_ABI;


const MAXUINT = 2 ** 256 - 1;
const MAX_UINT = etehrs.BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")

async function Getierc20() {
    const response = await fetch('/ABIs/ierc20.json');
    const jsonRes = await response.json();
    ierc20 = jsonRes;
}

async function GetFightNightABI() {
    const response = await fetch('/ABIs/FightNight_ABI.json');
    const jsonRes = await response.json();
    FightNight_ABI = jsonRes;
}

await Getierc20();
await GetFightNightABI();




// let web3Modal
// let selectedAccount;




document.getElementById("clickWallet").addEventListener("click", ConnectToWallet);
// document.getElementById("callReadFunction").addEventListener("click", callReadFunction);
document.getElementById("infromationOfNetwork").addEventListener('click', GetChainInformation);
document.getElementById("ApproveFunction").addEventListener('click', ApproveFunction);
document.getElementById("AllowanceFunction").addEventListener('click', AllowanceFunction);
document.getElementById("BalanceETH").addEventListener('click', BalanceETH);
document.getElementById("BalanceToken").addEventListener('click', BalanceToken);
document.getElementById("AddNetwork").addEventListener('click', AddNetwork);
document.getElementById("WalletStatus").addEventListener('click', WalletStatus);
// document.getElementById("WalletConnectQR").addEventListener('click', WalletConnectQR);
// document.getElementById("onDisconnect").addEventListener('click', onDisconnect);


async function ConnectToWallet() {
    if (window.ethereum !== 'undefined') {
        provider = new ethers.providers.Web3Provider(window.ethereum, "any");
        //  provider = ethers.getDefaultProvider();
        accounts = await provider.send("eth_requestAccounts", []);
        account = accounts[0];
        signer = await provider.getSigner();
        console.log("Account:", account);
    }
}
/*
async function WalletConnectQR() {
    const providerOptions = {
        walletconnect: {
            package: WalletConnectProvider,
            options: {
                // Mikko's test key - don't copy as your mileage may vary
                infuraId: "4c84ccb8dc7049aebf66a4dbd06a75e7",
                rpc: {
                    56: 'https://bsc-dataseed.binance.org/'
                },
                networkId: 56,
            }
            // options: {
            //   rpc: {
            //     56: 'https://bsc-dataseed.binance.org/'
            //   },
            //   network: 'binance',
            // }
        }
    }

    web3Modal = new Web3Modal({
        cacheProvider: false, // optional
        providerOptions, // required
        // network: "mainnet",
        disableInjectedProvider: true, // optional. For MetaMask / Brave / Opera.
    });

    try {
        provider = await web3Modal.connect();
    } catch (e) {
        console.log("Could not get a wallet connection", e);
        return;
    }

    // Subscribe to accounts change
    //   provider.on("accountsChanged", (accounts) => {
    //     fetchAccountData();
    //   });

    //   // Subscribe to chainId change
    //   provider.on("chainChanged", (chainId) => {
    //     fetchAccountData();
    //   });

    //   // Subscribe to networkId change
    //   provider.on("networkChanged", (networkId) => {
    //     fetchAccountData();
    //   });



    // Get an instance of the WalletConnect connector
    //   var walletConnector = new WalletConnect({
    //     bridge: 'https://bridge.walletconnect.org' // Required
    //   });


    // mainnet only
    //  const walletconnect = new WalletConnect({
    //     // rpc: { 1: NETWORK_URL },
    //     bridge: 'https://bridge.walletconnect.org',
    //     qrcode: true,
    //     pollingInterval: 15000
    //   })

    // // Create a connector
    // const connector = new WalletConnect({
    //     bridge: "https://bridge.walletconnect.org", // Required
    //     qrcodeModal: QRCodeModal,
    // });

    // // Check if connection is already established
    // if (!connector.connected) {
    //     // create new session
    //     connector.createSession();
    // }
}


async function onDisconnect() {

    // TODO: Which providers have close method?
    if (provider.close) {
        await provider.close();
        await web3Modal.clearCachedProvider();
        provider = null;
    }
    selectedAccount = null;
}
*/

async function WalletStatus() {
    if (provider) {
        accounts = await provider.send("eth_requestAccounts", []);
    }
    if (accounts && accounts.length > 0) {
        console.log("user is connected");
    } else {
        console.log("user not connected");
    }
}


// async function callReadFunction() {
//     let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
//     // provider = await ethers.getDefaultProvider("homestead");

//     const signer = await provider.getSigner();
//     const abi = ierc20;
//     const USDTContract = new ethers.Contract(tokenAddress, abi, signer);
//     const decimals = await USDTContract.decimals()
//     console.log(parseInt(decimals));
// }

async function GetChainInformation() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const {
        name,
        chainId
    } = await provider.getNetwork();
    console.log(name, chainId)
}

async function ApproveFunction(tokenAddress) {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const abi = ierc20;
    const contract = new ethers.Contract(tokenAddress, abi, signer);
    const tx = await contract['approve'](
        ContractAddressFight,
        MAXUINT
        // ethers.utils.parseEther("0.01")
        , {
            from: signer.getAddress()
        }
    )
    provider.sendTransaction(tx)
        .then((txObj) => {
            console.log('txHash', txObj.hash)
        })
}

async function AllowanceFunction(tokenAddress) {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const abi = ierc20;
    const contract = new ethers.Contract(tokenAddress, abi, signer);
    let allowance = await contract.allowance(signer.getAddress(), ContractAddressFight)
    allowance = ethers.utils.formatEther(allowance);
    console.log(allowance);
    return allowance;
}

async function BalanceETH() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const balance = await provider.getBalance(signer.getAddress());
    const balanceInEth = await ethers.utils.formatEther(balance)
    console.log(`balance: ${balanceInEth}`)
    return balance;
}

async function BalanceToken(tokenAddress) {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const abi = ierc20;
    const contract = new ethers.Contract(tokenAddress, abi, signer);
    let balance = await contract.balanceOf(signer.getAddress())
    balance = ethers.utils.formatEther(balance);
    console.log(balance);
    return balance;
}

async function setChainId(chainId) {
    switch (chainId) {
        case "0x89":
            window.ethereum.request({
                method: "wallet_addEthereumChain",
                params: [{
                    chainId: "0x89",
                    rpcUrls: ["https://rpc-mainnet.matic.network/"],
                    chainName: "Matic Mainnet",
                    nativeCurrency: {
                        name: "MATIC",
                        symbol: "MATIC",
                        decimals: 18
                    },
                    blockExplorerUrls: ["https://polygonscan.com/"]
                }]
            });
            break;

        case "1":
            ethereum.on('chainChanged', (chai1nId) => {
                console.log("change")
            });

            break;
    }
}

async function AddNetwork() {
    // For Test network
    setChainId("0x89");
}

async function GetUSDTBalance() {
    // testnet
    await getBalance(USDTContractAddress);
    // mainnet

}

async function GetBUSDBalance() {
    // testnet
    await getBalance(BUSDContractAddress);
    // mainnet

}

async function GetAwllowanceUSDT() {
    // testnet
    AllowanceFunction(USDTContractAddress);
    // mainnet

}
async function GetAwllowanceBUSD() {
    // testnet
    AllowanceFunction(BUSDContractAddress);
    // mainnet

}


async function GetPlayerinformation() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    // const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    const contract = new Contract(ContractAddressFight, FightNight_ABI);

    let Player_1_BUSD_Bet = contract.Player_1BUSDBet(signer.getAddress());
    let Player_1_BUSD_Pot = contract.Player_1BUSDPot(signer.getAddress());
    let Player_1_USDT_Bet = contract.Player_1USDTBet(signer.getAddress());
    let Player_1_USDT_Pot = contract.Player_1USDTPot(signer.getAddress());
    let Player_2_BUSD_Bet = contract.Player_2BUSDBet(signer.getAddress());
    let Player_2_BUSD_Pot = contract.Player_2BUSDPot(signer.getAddress());
    let Player_2_USDT_Bet = contract.Player_2USDTBet(signer.getAddress());
    let Player_2_USDT_Pot = contract.Player_2USDTPot(signer.getAddress());

    let InformationClientforPlayers = await provider.all(Player_1_BUSD_Bet, Player_1_BUSD_Pot,
        Player_1_USDT_Bet, Player_1_USDT_Pot, Player_2_BUSD_Bet, Player_2_BUSD_Pot, Player_2_USDT_Bet, Player_2_USDT_Pot);

    return InformationClientforPlayers;
}

async function HowMuchEarn() {
    let provider = new ethers.provider.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    let [busdEarn, usdtEarn] = await contract.earned(signer.getAddress());
    console.log(busdEarn, usdtEarn);
    return (busdEarn, usdtEarn);
}

async function isCanceledF() {
    let provider = new ethers.provider.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    let isCanceled = await contract.isCanceled();
    console.log(isCanceled);
    return (isCanceled);
}


async function isPausedF() {
    let provider = new ethers.provider.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    let isPaused = await contract.isPaused();
    console.log(isPaused);
    return (isPaused);
}

async function BUSDBetFunction(fighter, amount) {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    const tx = await contract['BUSDBet'](
        fighter,
        ethers.utils.parseEther(amount)
        // ethers.utils.parseEther("0.01")      Use String for input please  :/
        , {
            from: signer.getAddress()
        }
    )
    provider.sendTransaction(tx)
        .then((txObj) => {
            console.log('txHash', txObj.hash)
        })
}

async function USDTBetFunction(fighter, amount) {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    const tx = await contract['USDTBet'](
        fighter,
        ethers.utils.parseEther(amount)
        // ethers.utils.parseEther("0.01")      
        , {
            from: signer.getAddress()
        }
    )
    provider.sendTransaction(tx)
        .then((txObj) => {
            console.log('txHash', txObj.hash)
        })
}

async function FinalizeFightFunction(fighter) {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(ContractAddressFight, FightNight_ABI, signer);
    const tx = await contract['finalizeFight'](
        fighter, {
            from: signer.getAddress()
        }
    )
    provider.sendTransaction(tx)
        .then((txObj) => {
            console.log('txHash', txObj.hash)
        })
}