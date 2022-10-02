// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EPay {
    mapping(address => uint256) private s_addressToSentAmount;
    mapping(address => mapping(address => uint256)) private s_allowance;

    function send() public payable {
        s_addressToSentAmount[msg.sender] += msg.value;
    }

    function approve(address _to, uint256 _value) public {
        require(_to != address(0x0), "Address zero is not allowed!");
        uint256 _valueInEth = _value * 10**18;
        require(
            s_addressToSentAmount[msg.sender] >= _valueInEth,
            "Not enough ETH!"
        );
        s_allowance[msg.sender][_to] = _valueInEth;
    }

    function increaseAllowance(address _to, uint256 _value) public {
        require(_to != address(0x0), "Address zero is not allowed!");
        uint256 _valueInEth = _value * 10**18;
        require(
            s_addressToSentAmount[msg.sender] >= _valueInEth,
            "Not enough ETH!"
        );
        s_allowance[msg.sender][_to] += _valueInEth;
    }

    function decreaseAllowance(address _to, uint256 _value) public {
        require(_to != address(0x0), "Address zero is not allowed!");
        uint256 _valueInEth = _value * 10**18;
        require(
            s_addressToSentAmount[msg.sender] >= _valueInEth,
            "Not enough ETH!"
        );
        require(
            s_allowance[msg.sender][_to] >= _valueInEth,
            "Not enough allowance!"
        );
        s_allowance[msg.sender][_to] -= _valueInEth;
    }

    function withdraw(uint256 _amount) public payable {
        uint256 _amountInEth = _amount * 10**18;
        require(
            s_addressToSentAmount[msg.sender] >= _amountInEth,
            "Not enough ETH!"
        );
        s_addressToSentAmount[msg.sender] -= _amountInEth;
        (bool callSuccess, ) = payable(msg.sender).call{value: _amountInEth}(
            ""
        );
        require(callSuccess, "Call failed");
    }

    function withdrawFrom(address _from, uint256 _amount) public payable {
        uint256 _amountInEth = _amount * 10**18;
        require(_from != address(0x0), "Address zero is not allowed!");
        require(
            s_allowance[_from][msg.sender] >= _amountInEth,
            "Not enough allowance!"
        );
        s_addressToSentAmount[_from] -= _amountInEth;
        s_allowance[_from][msg.sender] -= _amountInEth;
        (bool callSuccess, ) = payable(msg.sender).call{value: _amountInEth}(
            ""
        );
        require(callSuccess, "Call failed");
    }

    function getSentAmount(address _from) public view returns (uint256) {
        return s_addressToSentAmount[_from];
    }

    function getAllowance(address _from, address _to)
        public
        view
        returns (uint256)
    {
        return s_allowance[_from][_to];
    }
}
