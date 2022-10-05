// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EPay {
  mapping(address => uint256) private s_addressToSentAmount;
  mapping(address => mapping(address => uint256)) private s_allowance;

  event EthSent(address sender, uint256 value);
  event Approval(address from, address to, uint256 value);
  event AllowanceIncreased(
    address from,
    address to,
    uint256 increasingValue,
    uint256 newValue
  );
  event AllowanceDecreased(
    address from,
    address to,
    uint256 decreasingValue,
    uint256 newValue
  );
  event Withdrawal(address recipientAddress, uint256 value);

  function send() public payable {
    s_addressToSentAmount[msg.sender] += msg.value;
    emit EthSent(msg.sender, msg.value);
  }

  function approve(address _to, uint256 _value) public {
    require(_to != address(0x0), "Address zero is not allowed!");
    uint256 _valueInEth = _value * 10**18;
    require(
      s_addressToSentAmount[msg.sender] >= _valueInEth,
      "Not enough ETH!"
    );
    s_allowance[msg.sender][_to] = _valueInEth;
    emit Approval(msg.sender, _to, _value);
  }

  function increaseAllowance(address _to, uint256 _value) public {
    require(_to != address(0x0), "Address zero is not allowed!");
    uint256 _valueInEth = _value * 10**18;
    require(
      s_addressToSentAmount[msg.sender] >= _valueInEth,
      "Not enough ETH!"
    );
    s_allowance[msg.sender][_to] += _valueInEth;
    emit AllowanceIncreased(
      msg.sender,
      _to,
      _value,
      s_allowance[msg.sender][_to] / (10**18)
    );
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
    emit AllowanceDecreased(
      msg.sender,
      _to,
      _value,
      s_allowance[msg.sender][_to] / (10**18)
    );
  }

  function withdraw(uint256 _amount) public payable {
    uint256 _amountInEth = _amount * 10**18;
    require(
      s_addressToSentAmount[msg.sender] >= _amountInEth,
      "Not enough ETH!"
    );
    s_addressToSentAmount[msg.sender] -= _amountInEth;
    (bool callSuccess, ) = payable(msg.sender).call{value: _amountInEth}("");
    require(callSuccess, "Call failed");
    emit Withdrawal(msg.sender, _amount);
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
    (bool callSuccess, ) = payable(msg.sender).call{value: _amountInEth}("");
    require(callSuccess, "Call failed");
    emit Withdrawal(msg.sender, _amount);
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
