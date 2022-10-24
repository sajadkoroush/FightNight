// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward, uint256 _duration) virtual external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {
        rewardDistribution = _rewardDistribution;
    }
}

contract FightNight_V1_BUSD_USDT is IRewardDistributionRecipient {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public croupier;

    enum Fighter {
        Undecided,
        Rookie,
        Loomdart
    }

    // IERC20 public token;
    IERC20 public BUSD;
    IERC20 public USDT;

    string public constant desc = "CT Fight Night Dubai 2021: RookieXBT vs Loomdart";

    uint256 public constant endTime = 1634400000;
    uint256 public constant lastClaimTime = endTime + 1 days * 365 * 0.25;

    bool public isPaused;
    bool public isCanceled;
    bool public isFinal;
    bool public isFeesClaimed;

    Fighter public winner;

    // mapping(address => uint256) public LoomdartBUSDBet;
    // mapping(address => uint256) public RookieBUSDBet;
    // mapping(address => uint256) public LoomdartUSDTBet;
    // mapping(address => uint256) public RookieUSDTBet;

    mapping(address => uint256) public loomdartBUSDBet;
    mapping(address => uint256) public rookieBUSDBet;
    mapping(address => uint256) public loomdartUSDTBet;
    mapping(address => uint256) public rookieUSDTBet;

    uint256 public loomdartBUSDPot;
    uint256 public rookieBUSDPot;
    uint256 public loomdartUSDTPot;
    uint256 public rookieUSDTPot;

    event LoomdartBUSDBet(address indexed user, uint256 amount);
    event RookieBUSDBet(address indexed user, uint256 amount);
    event LoomdartUSDTBet(address indexed user, uint256 amount);
    event RookieUSDTBet(address indexed user, uint256 amount);

    event EarningsPaid(address indexed user, uint256 busdEarnings, uint256 usdtEarnings);

    modifier checkStatus() {
        require(!isFinal, "fight is decided");
        require(!isCanceled, "fight is canceled, claim your bet");
        require(!isPaused, "betting not started");
        require(block.timestamp < endTime, "betting has ended");
        _;
    }

    constructor(address _croupier, address _busd, address _usdt ) {
        croupier = _croupier;
        // token = IERC20(_token);
        BUSD = IERC20(_busd);
        USDT = IERC20(_usdt);
        rewardDistribution = msg.sender;
    }

    // function BNBBet(Fighter fighter) public payable checkStatus {
    //     require(msg.value != 0, "no bnb sent");
    //     if (fighter == Fighter.Loomdart) {
    //         LoomdartBUSDBet[msg.sender] += msg.value;
    //         loomdartBUSDPot += msg.value;
    //         emit LoomdartBUSDBet(msg.sender, msg.value);
    //     } else if (fighter == Fighter.Rookie) {
    //         RookieBUSDBet[msg.sender] += msg.value;
    //         rookieBUSDPot += msg.value;
    //         emit RookieBUSDBet(msg.sender, msg.value);
    //     } else {
    //         revert("LFG! Pick one already!");
    //     }
    // }

    function BUSDBet(Fighter fighter, uint256 amount) public checkStatus {
        require(amount != 0, "no token sent");
        if (fighter == Fighter.Loomdart) {
            uint256 _before = BUSD.balanceOf(address(this));
            BUSD.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = BUSD.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            LoomdartBUSDBet[msg.sender] += _amount;
            loomdartBUSDPot += _amount;
            emit LoomdartBUSDBet(msg.sender, _amount);
        } else if (fighter == Fighter.Rookie) {
            uint256 _before = BUSD.balanceOf(address(this));
            BUSD.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = BUSD.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            RookieBUSDBet[msg.sender] += _amount;
            rookieBUSDPot += _amount;
            emit RookieBUSDBet(msg.sender, _amount);
        } else {
            revert("LFG! Pick one already!");
        }
    }

    function USDTBet(Fighter fighter, uint256 amount) public checkStatus {
        require(amount != 0, "no token sent");
        if (fighter == Fighter.Loomdart) {
            uint256 _before = USDT.balanceOf(address(this));
            USDT.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = USDT.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            LoomdartUSDTBet[msg.sender] += _amount;
            loomdartUSDTPot += _amount;
            emit LoomdartUSDTBet(msg.sender, _amount);
        } else if (fighter == Fighter.Rookie) {
            uint256 _before = USDT.balanceOf(address(this));
            USDT.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = USDT.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            RookieUSDTBet[msg.sender] += _amount;
            rookieUSDTPot += _amount;
            emit RookieUSDTBet(msg.sender, _amount);
        } else {
            revert("LFG! Pick one already!");
        }
    }

    function pauseBetting() external onlyRewardDistribution {
        isPaused = true;
    }

    function unpauseBetting() external onlyRewardDistribution {
        isPaused = false;
    }

    function cancelFight() external onlyRewardDistribution {
        require(!isFinal, "fight is decided");
        isCanceled = true;
    }

    function finalizeFight(Fighter fighter) external onlyRewardDistribution {
        require(!isFinal, "fight is decided");
        require(!isCanceled, "fight is canceled");
        require(fighter == Fighter.Loomdart || fighter == Fighter.Rookie, "invalid fighter");
        winner = fighter;
        isFinal = true;
    }

    function getFees() external onlyRewardDistribution returns (uint256 busdFees, uint256 usdtFees) {
        require(!isFeesClaimed, "fees claimed");
        if (isFinal) {
            isFeesClaimed = true;

            if (winner == Fighter.Loomdart) {
                busdFees = rookieBUSDPot.mul(1e18).div(1e20);
                if (busdFees != 0) {
                    _safeTransfer(busdFees, true);
                }
                usdtFees = rookieUSDTPot.mul(1e18).div(1e20);
                if (usdtFees != 0) {
                    _safeTransfer(usdtFees, false);
                }
            } else if (winner == Fighter.Rookie) {
                busdFees = loomdartBUSDPot.mul(1e18).div(1e20);
                if (busdFees != 0) {
                    _safeTransfer(busdFees, true);
                }
                usdtFees = loomdartUSDTPot.mul(1e18).div(1e20);
                if (usdtFees != 0) {
                    _safeTransfer(usdtFees, false);
                }
            }
        }
    }


    // double Check for tokens please :/
    function rescueFunds(address tokenAddress) external onlyRewardDistribution {
        if (tokenAddress == address(0)) {
            Address.sendValue(payable(msg.sender), address(this).balance);
        } else {
            IERC20(token).safeTransfer(payable(msg.sender), IERC20(tokenAddress).balanceOf(address(this)));
        }
    }

    function earned(address account) public view returns (uint256 busdEarnings, uint256 usdtEarnings) {
        if (isFinal) {
            uint256 _LoomdartBUSDBet = LoomdartBUSDBet[account];
            uint256 _RookieBUSDBet = RookieBUSDBet[account];
            uint256 _LoomdartUSDTBet = LoomdartUSDTBet[account];
            uint256 _RookieUSDTBet = RookieUSDTBet[account];

            uint256 winnings;
            uint256 fee;

            if (winner == Fighter.Loomdart && _LoomdartBUSDBet != 0) {
                winnings = rookieBUSDPot.mul(_LoomdartBUSDBet).div(loomdartBUSDPot);
                fee = winnings.mul(1e18).div(1e20);
                winnings = winnings.sub(fee);
                busdEarnings = _LoomdartBUSDBet.add(winnings);
            } else if (winner == Fighter.Rookie && _RookieBUSDBet != 0) {
                winnings = loomdartBUSDPot.mul(_RookieBUSDBet).div(rookieBUSDPot);
                fee = winnings.mul(1e18).div(1e20);
                winnings = winnings.sub(fee);
                busdEarnings = _RookieBUSDBet.add(winnings);
            }

            if (winner == Fighter.Loomdart && _LoomdartUSDTBet != 0) {
                winnings = rookieUSDTPot.mul(_LoomdartUSDTBet).div(loomdartUSDTPot);
                fee = winnings.mul(1e18).div(1e20);
                winnings = winnings.sub(fee);
                usdtEarnings = _LoomdartUSDTBet.add(winnings);
            } else if (winner == Fighter.Rookie && _RookieUSDTBet != 0) {
                winnings = loomdartUSDTPot.mul(_RookieUSDTBet).div(rookieUSDTPot);
                fee = winnings.mul(1e18).div(1e20);
                winnings = winnings.sub(fee);
                usdtEarnings = _RookieUSDTBet.add(winnings);
            }
        } else if (isCanceled) {
            busdEarnings = LoomdartBUSDBet[account] + RookieBUSDBet[account];
            usdtEarnings = LoomdartUSDTBet[account] + RookieUSDTBet[account];
        }
    }

    function getRewards() public {
        require(isFinal || isCanceled, "fight not decided");

        (uint256 busdEarnings, uint256 usdtEarnings) = earned(msg.sender);
        if (busdEarnings != 0) {
            LoomdartBUSDBet[msg.sender] = 0;
            RookieBUSDBet[msg.sender] = 0;
            _safeTransfer(busdEarnings, true);
        }
        if (usdtEarnings != 0) {
            LoomdartUSDTBet[msg.sender] = 0;
            RookieUSDTBet[msg.sender] = 0;
            _safeTransfer(usdtEarnings, false);
        }
        emit EarningsPaid(msg.sender, busdEarnings, usdtEarnings);
    }

    function _safeTransfer(uint256 _amount, bool isBUSD) internal {
        uint256 _balance;
        if (isBUSD) {
            _balance = BUSD.balanceOf(address(this));
            if (_amount > _balance) {
                _amount = _balance;
            }
            BUSD.safeTransfer(msg.sender, _amount);
        } else {
            _balance = USDT.balanceOf(address(this));
            if (_amount > _balance) {
                _amount = _balance;
            }
            USDT.safeTransfer(msg.sender, _amount);
        }
    }

    // function setToken(address _token) external onlyOwner {
    //     require(_token != address(0x0));
    //     token = IERC20(_token);
    // }

    function setCroupier(address _addr) public onlyOwner {
        croupier = _addr;
    }

    // unused
    function notifyRewardAmount(uint256, uint256) external override pure { return; }
}
