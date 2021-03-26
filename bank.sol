pragma solidity 0.6.6;


contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        _assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        _assert(b > 0);
        uint256 c = a / b;
        _assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        _assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        _assert(c >= a && c >= b);
        return c;
    }

    function _assert(bool assertion) internal pure {
        if (!assertion) {
            revert();
        }
    }
}


contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage is SafeMath , Owned {
    uint public currUserID = 0;
    uint256 number = 0;
    uint256 min = 5;
    uint256 max = 8;
    bytes[] listdata;

    struct UserStruct {
        bool isExist;
        uint id;
        uint total;
    }
    mapping(address=>UserStruct)users;
    mapping(address=>uint)_banlance;
    event Transfer(address indexed _from, address indexed _to, uint256 value);

    constructor() public {
        _banlance[msg.sender] = 0;
    }

    /**
     * @dev Store value in variable
     收eth
     */
    function store() public payable{

        if(_banlance[msg.sender] > 0)
        {
            _banlance[msg.sender] = msg.value;
        }
        else
        {
            _banlance[msg.sender] = safeAdd(_banlance[msg.sender],msg.value);
        }
        number = safeAdd(number,msg.value);
    }

    // ------------------------------------------------------------------------
    //  ERC20 tokens  收代币
    // -----------------------------------------
    receive() external  payable{
        if(_banlance[msg.sender] > 0)
        {
            _banlance[msg.sender] = msg.value;
        }
        else
        {
            _banlance[msg.sender] = safeAdd(_banlance[msg.sender],msg.value);
        }
        number = safeAdd(number,msg.value);
    }

    /*
        get the store
    */

    function balanceOf(address tokenOwner) public  view returns (uint balance) {
        if(_banlance[tokenOwner] > 0)
        {
            return _banlance[tokenOwner];
        }
        else
        {
            return 0;
        }
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function withdraw(address to) public  returns (bool success) {
        require(to != address(0));
        require(_banlance[msg.sender] > 0);

        number = safeSub(number,_banlance[msg.sender]);
        address(uint160(msg.sender)).transfer(_banlance[msg.sender]);
        _banlance[msg.sender] = 0;

        emit Transfer(owner , msg.sender, _banlance[msg.sender]);
        return true;
    }



    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public  onlyOwner {
        // return ERC20Interface(tokenAddress).transfer(owner, tokens);
        address(uint160(tokenAddress)).transfer(tokens);
        emit Transfer(owner,tokenAddress,tokens);
    }

    // ------------------------------------------------------------------------
    //  ERC20 withdraw
    // -----------------------------------------
    function withdrawERC20() onlyOwner public {
        msg.sender.transfer(address(this).balance);
    }


    /*
        rate 0.5-0.8
    */
    function set_min_rate(uint256 num) public onlyOwner{
        min = num;
    }

    function set_max_rate(uint256 num) public onlyOwner{
        max = num;
    }


    /**
     * @dev Return value
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
