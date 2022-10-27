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
        Player_2,
        Player_1
    }

    // IERC20 public token;
    IERC20 public BUSD;
    IERC20 public USDT;

    string public constant desc = "Fight Night Dubai 2022: Player1 vs Player2";

    // most be double check it again for make end of time :/
    uint256 public constant endTime = 1634400000;

    bool public isPaused;
    bool public isCanceled;
    bool public isFinal;
    bool public isFeesClaimed;

    Fighter public winner;

    // mapping(address => uint256) public Player_1BUSDBet;
    // mapping(address => uint256) public Player_2BUSDBet;
    // mapping(address => uint256) public Player_1USDTBet;
    // mapping(address => uint256) public Player_2USDTBet;

    mapping(address => uint256) public Player_1BUSDBet;
    mapping(address => uint256) public Player_2BUSDBet;
    mapping(address => uint256) public Player_1USDTBet;
    mapping(address => uint256) public Player_2USDTBet;

    uint256 public Player_1BUSDPot;
    uint256 public Player_2BUSDPot;
    uint256 public Player_1USDTPot;
    uint256 public Player_2USDTPot;

    event Player_1BUSDBetevent(address indexed user, uint256 amount);
    event Player_2BUSDBetevent(address indexed user, uint256 amount);
    event Player_1USDTBetevent(address indexed user, uint256 amount);
    event Player_2USDTBetevent(address indexed user, uint256 amount);

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
    //     if (fighter == Fighter.Player_1) {
    //         Player_1BUSDBet[msg.sender] += msg.value;
    //         Player_1BUSDPot += msg.value;
    //         emit Player_1BUSDBet(msg.sender, msg.value);
    //     } else if (fighter == Fighter.Player_2) {
    //         Player_2BUSDBet[msg.sender] += msg.value;
    //         Player_2BUSDPot += msg.value;
    //         emit Player_2BUSDBet(msg.sender, msg.value);
    //     } else {
    //         revert("LFG! Pick one already!");
    //     }
    // }

    function BUSDBet(Fighter fighter, uint256 amount) public checkStatus {
        require(amount != 0, "no token sent");
        if (fighter == Fighter.Player_1) {
            uint256 _before = BUSD.balanceOf(address(this));
            BUSD.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = BUSD.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            Player_1BUSDBet[msg.sender] += _amount;
            Player_1BUSDPot += _amount;
            emit Player_1BUSDBetevent(msg.sender, _amount);
        } else if (fighter == Fighter.Player_2) {
            uint256 _before = BUSD.balanceOf(address(this));
            BUSD.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = BUSD.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            Player_2BUSDBet[msg.sender] += _amount;
            Player_2BUSDPot += _amount;
            emit Player_2BUSDBetevent(msg.sender, _amount);
        } else {
            revert("LFG! Pick one already!");
        }
    }

    function USDTBet(Fighter fighter, uint256 amount) public checkStatus {
        require(amount != 0, "no token sent");
        if (fighter == Fighter.Player_1) {
            uint256 _before = USDT.balanceOf(address(this));
            USDT.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = USDT.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            Player_1USDTBet[msg.sender] += _amount;
            Player_1USDTPot += _amount;
            emit Player_1USDTBetevent(msg.sender, _amount);
        } else if (fighter == Fighter.Player_2) {
            uint256 _before = USDT.balanceOf(address(this));
            USDT.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _after = USDT.balanceOf(address(this));
            uint256 _amount = _after.sub(_before);
            Player_2USDTBet[msg.sender] += _amount;
            Player_2USDTPot += _amount;
            emit Player_2USDTBetevent(msg.sender, _amount);
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
        require(fighter == Fighter.Player_1 || fighter == Fighter.Player_2, "invalid fighter");
        winner = fighter;
        isFinal = true;
    }

    function getFees() external onlyRewardDistribution returns (uint256 busdFees, uint256 usdtFees) {
        require(!isFeesClaimed, "fees claimed");
        if (isFinal) {
            isFeesClaimed = true;

            if (winner == Fighter.Player_1) {
                busdFees = Player_2BUSDPot.mul(1e18).div(1e19);
                if (busdFees != 0) {
                    _safeTransfer(busdFees, true);
                }
                usdtFees = Player_2USDTPot.mul(1e18).div(1e19);
                if (usdtFees != 0) {
                    _safeTransfer(usdtFees, false);
                }
            } else if (winner == Fighter.Player_2) {
                busdFees = Player_1BUSDPot.mul(1e18).div(1e19);
                if (busdFees != 0) {
                    _safeTransfer(busdFees, true);
                }
                usdtFees = Player_1USDTPot.mul(1e18).div(1e19);
                if (usdtFees != 0) {
                    _safeTransfer(usdtFees, false);
                }
            }
        }
    }


    // double Check for tokens please :/
    // function rescueFunds(address tokenAddress) external onlyRewardDistribution {
    //     if (tokenAddress == address(0)) {
    //         Address.sendValue(payable(msg.sender), address(this).balance);
    //     } else {
    //         IERC20(token).safeTransfer(payable(msg.sender), IERC20(tokenAddress).balanceOf(address(this)));
    //     }
    // }

    function earned(address account) public view returns (uint256 busdEarnings, uint256 usdtEarnings) {
        if (isFinal) {
            uint256 _Player_1BUSDBet = Player_1BUSDBet[account];
            uint256 _Player_2BUSDBet = Player_2BUSDBet[account];
            uint256 _Player_1USDTBet = Player_1USDTBet[account];
            uint256 _Player_2USDTBet = Player_2USDTBet[account];

            uint256 winnings;
            uint256 fee;

            if (winner == Fighter.Player_1 && _Player_1BUSDBet != 0) {
                winnings = Player_2BUSDPot.mul(_Player_1BUSDBet).div(Player_1BUSDPot);
                fee = winnings.mul(1e18).div(1e19);
                winnings = winnings.sub(fee);
                busdEarnings = _Player_1BUSDBet.add(winnings);
            } else if (winner == Fighter.Player_2 && _Player_2BUSDBet != 0) {
                winnings = Player_1BUSDPot.mul(_Player_2BUSDBet).div(Player_2BUSDPot);
                fee = winnings.mul(1e18).div(1e19);
                winnings = winnings.sub(fee);
                busdEarnings = _Player_2BUSDBet.add(winnings);
            }

            if (winner == Fighter.Player_1 && _Player_1USDTBet != 0) {
                winnings = Player_2USDTPot.mul(_Player_1USDTBet).div(Player_1USDTPot);
                fee = winnings.mul(1e18).div(1e19);
                winnings = winnings.sub(fee);
                usdtEarnings = _Player_1USDTBet.add(winnings);
            } else if (winner == Fighter.Player_2 && _Player_2USDTBet != 0) {
                winnings = Player_1USDTPot.mul(_Player_2USDTBet).div(Player_2USDTPot);
                fee = winnings.mul(1e18).div(1e19);
                winnings = winnings.sub(fee);
                usdtEarnings = _Player_2USDTBet.add(winnings);
            }
        } else if (isCanceled) {
            busdEarnings = Player_1BUSDBet[account] + Player_2BUSDBet[account];
            usdtEarnings = Player_1USDTBet[account] + Player_2USDTBet[account];
        }
    }

    function getRewards() public {
        require(isFinal || isCanceled, "fight not decided");

        (uint256 busdEarnings, uint256 usdtEarnings) = earned(msg.sender);
        if (busdEarnings != 0) {
            Player_1BUSDBet[msg.sender] = 0;
            Player_2BUSDBet[msg.sender] = 0;
            _safeTransfer(busdEarnings, true);
        }
        if (usdtEarnings != 0) {
            Player_1USDTBet[msg.sender] = 0;
            Player_2USDTBet[msg.sender] = 0;
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
