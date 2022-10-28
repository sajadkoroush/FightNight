// import * as ierc20 from './ABIs/ierc20.json' // assert {type: 'json'};

// import WalletConnect from 'walletconnect/client';
"use strict";

// const Web3Modal = window.Web3Modal.default;
// const WalletConnectProvider = window.WalletConnectProvider.default;
// // const Fortmatic = window.Fortmatic;
// const evmChains = window.evmChains;



let ierc20;
let tokenAddress = "0xEC5dCb5Dbf4B114C9d0F65BcCAb49EC54F6A0867";
await Getierc20();

let provider;
let accounts;
let account;
let signer;

const MAXUINT = 2 **256 - 1;
const MAX_UINT = etehrs.BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")

async function Getierc20() {
    const response = await fetch('/ABIs/ierc20.json');
    const jsonRes = await response.json();
    ierc20 = jsonRes;
}


// let web3Modal
// let selectedAccount;




document.getElementById("clickWallet").addEventListener("click", ConnectToWallet);
document.getElementById("callReadFunction").addEventListener("click", callReadFunction);
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


async function callReadFunction() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    // provider = await ethers.getDefaultProvider("homestead");

    const signer = await provider.getSigner();
    const abi = ierc20;
    const USDTContract = new ethers.Contract(tokenAddress, abi, signer);
    const decimals = await USDTContract.decimals()
    console.log(parseInt(decimals));
}

async function GetChainInformation() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const {
        name,
        chainId
    } = await provider.getNetwork();
    console.log(name, chainId)
}

async function ApproveFunction() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const abi = ierc20;
    const contract = new ethers.Contract(tokenAddress, abi, signer);
    const tx = await contract['approve'](
        signer.getAddress(),
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

async function AllowanceFunction() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const abi = ierc20;
    const contract = new ethers.Contract(tokenAddress, abi, signer);
    let allowance = await contract.allowance(signer.getAddress(), signer.getAddress())
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

async function BalanceToken() {
    let provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    const signer = await provider.getSigner();
    const abi = ierc20;
    const contract = new ethers.Contract(tokenAddress, abi, signer);
    let balance = await contract.balanceOf(signer.getAddress())
    balance = ethers.utils.formatEther(balance);
    console.log(balance);
    return balance;
}


async function AddNetwork() {
    setChainId("0x89");
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
