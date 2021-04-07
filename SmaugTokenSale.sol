/**
 *Submitted for verification at BscScan.com on 2021-02-27
*/

pragma solidity ^0.4.26;

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

/**
ERC Token Standard #20 Interface
https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
*/
contract IERC20 {
    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner)
        public
        constant
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        constant
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

/**
Contract function to receive approval and execute function in one call
Borrowed from MiniMeToken
*/
contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes data
    ) public;
}

contract SmaugPublicSale {
    address public manager; // ***BNB's destination address***

    bool public active; // ***Active ?***

    mapping(address => uint256) public investorsDepositedBNB; // ***All investors and their BNB deposits***

    mapping(address => uint256) public investorsDepositedSMAUG; // *** SMAUG equivalent of all investors and BNB deposits ***

    mapping(address => bool) public isInvested;

    address[] public allInvestors; // ***All investors***

    uint256 public totalInvestmentSMAUG; // ***Total purchased SMAUG***

    uint256 public totalInvestmentBNB; // ***Total BNB deposited***

    IERC20 public SmaugToken =
        IERC20(0xaD5668bFd8274532555db78D84FC4a4D74A57b7D); // ***SmaugToken Contract***

    uint256 public SMAUGperBNB = 2333300000000; // 1 BNB = 23333 Smaug

    uint256 public maxBNB = 150000000000;  // ***Maximum BNB that can be deposited***
                            
    uint256 public maxSMAUG = 3500000000000000; // ***Maximum SMAUG that can be purchased***

    constructor() public {
        manager = msg.sender; // ***Set Manager***
        active = false;
    }

    modifier isManager() {
        require(manager == msg.sender); // ***The transferring address must match the manager address.***
        _;
    }

    function changeActive(bool _active) public isManager {
        // ***Change Active***
        active = _active;
    }

    function buy() public payable returns (uint256) {
        require(active); // ***If Active***
        // ***Buy Tokens***
        require(totalInvestmentBNB + msg.value <= maxBNB); // ***BNB sent and total BNB deposited cannot be greater than the maximum BNB amount***
        require(
            totalInvestmentSMAUG +
                ((msg.value * SMAUGperBNB) / 100000000) <=
                maxSMAUG
        ); // ***The sum of SMAUG to be purchased and SMAUG to be purchased cannot be greater than the SMAUG to be sold.***
        require(msg.value >= 10000000);
                              // ***The BNB sent must be greater than 0.1 BNB.***
        require(
            investorsDepositedBNB[msg.sender] + msg.value <=
                1000000000
        ); // ***The sum of the deposited and sent amount must be less than 10 BNB***

        uint256 smaugamount = (msg.value * SMAUGperBNB) / 100000000; // ***Amount of SmaugToken to be sent***

        investorsDepositedBNB[msg.sender] =
            investorsDepositedBNB[msg.sender] +
            msg.value; // ***Adding how many BNB the investor has deposited***
        investorsDepositedSMAUG[msg.sender] =
            investorsDepositedSMAUG[msg.sender] +
            smaugamount; // ***Adding how many BNB equivalent SMAUG the investor has deposited***

        if (isInvested[msg.sender]) {} else {
            // ***If no investment has been made***
            allInvestors.push(msg.sender); // ***Adding all investors***
            isInvested[msg.sender] = true; // ***Set Invested***
        
        }
        totalInvestmentBNB += msg.value; // ***Adding totalInvestmentBNB
        totalInvestmentSMAUG += smaugamount; // ***Adding totalInvestmentSMAUG

           
    }

    function sendInvestorsTokens() public isManager {
        // ***Distribution of SMAUG Token to investors.***
        for (uint256 i = 0; i < allInvestors.length; i++) {
             SmaugToken.transfer( allInvestors[i], investorsDepositedSMAUG[allInvestors[i]]);
      
        }
    }

    function getAllInvestors() public view returns (address[]) {
        return allInvestors;
    }

    function getSMAUGTokenDeployer(uint256 amount) public isManager {
        // ***Send SMAUGTOKEN to DEPLOYER***
        SmaugToken.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) public isManager {
        // ***Send BNB to manager
        manager.transfer(amount);
    }

    function getAllBNB() public isManager {
        // Send all BNB's to manager
        manager.transfer(address(this).balance);
    }
}