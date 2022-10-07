// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract UpdatedEPay {
  mapping(address => uint256) public s_addressToSentAmount;
  mapping(address => mapping(address => uint256)) public s_startingTime;
  uint256 public constant DURATION = 3 minutes;

  event EthSent(address _from, uint256 _value, uint256 _total);
  event Approval(address _from, address _to, uint256 _value, bytes32 _message);
  event Withdrawal(address _from, address _to, uint256 _value);

  function send() public payable returns (bool success) {
    s_addressToSentAmount[msg.sender] += msg.value;
    emit EthSent(msg.sender, msg.value, s_addressToSentAmount[msg.sender]);
    return true;
  }

  /**
    This fuction is used to return message hash
    and then it can be used to generate a new signature 
    */
  function _getMessageHash(
    uint256 _value,
    address _from,
    address _to,
    uint256 _startingTime
  ) internal pure returns (bytes32) {
    bytes32 messageHash = keccak256(
      abi.encodePacked(
        keccak256(abi.encodePacked(_value, _from)),
        keccak256(abi.encodePacked(_to, _startingTime))
      )
    );
    return messageHash;
  }

  /**
    This function returns a string with Ethereum prefix
    and then it can be used to verify the signature
    */
  function _getMessageHashWithPrefix(
    uint256 _value,
    address _from,
    address _to,
    uint256 _startingTime
  ) internal pure returns (bytes32) {
    bytes32 messageHash = _getMessageHash(_value, _from, _to, _startingTime);
    bytes32 messageHashWithPrefix = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    );
    return messageHashWithPrefix;
  }

  /** 
    The client side will call this function and get the hash message,
    then using the hash message with their private key to create a signature
  */
  function approve(uint256 _value, address _to) public returns (bool) {
    uint256 valueInEth = _value * 10**18;
    require(s_addressToSentAmount[msg.sender] >= valueInEth, "Not enough ETH!");
    uint256 startingTime = block.timestamp;
    bytes32 messageHash = _getMessageHash(
      _value,
      msg.sender,
      _to,
      startingTime
    );
    s_startingTime[msg.sender][_to] = startingTime;
    emit Approval(msg.sender, _to, _value, messageHash);
    return true;
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
    emit Withdrawal(msg.sender, msg.sender, _amount);
  }

  function withdrawFrom(
    address _from,
    uint256 _value,
    bytes memory _sig
  ) public payable returns (bool success) {
    require(
      block.timestamp <= s_startingTime[_from][msg.sender] + DURATION,
      "Time's up or Starting Time has been deleted!"
    );
    uint256 valueInEth = _value * 10**18;
    require(s_addressToSentAmount[_from] >= valueInEth, "Not enough ETH!");
    bool isVerified = _verify(_from, msg.sender, _value, _sig);
    require(isVerified, "Verification Error!");
    // if (!isVerified) return false;
    s_addressToSentAmount[_from] -= valueInEth;
    delete s_startingTime[_from][msg.sender];
    (bool callSuccess, ) = payable(msg.sender).call{value: valueInEth}("");
    require(callSuccess, "Call failed");
    emit Withdrawal(_from, msg.sender, _value);
    return true;
  }

  function _verify(
    address _from,
    address _to,
    uint256 _value,
    bytes memory _signature
  ) internal view returns (bool) {
    bytes32 messageHashWithPrefix = _getMessageHashWithPrefix(
      _value,
      _from,
      _to,
      s_startingTime[_from][_to]
    );
    return _recoverSigner(messageHashWithPrefix, _signature) == _from;
  }

  function _recoverSigner(bytes32 _messageHash, bytes memory _signature)
    internal
    pure
    returns (address)
  {
    (bytes32 r, bytes32 s, uint8 v) = _splitSignature(_signature);
    address result = ecrecover(_messageHash, v, r, s);
    return result;
  }

  function _splitSignature(bytes memory _signature)
    internal
    pure
    returns (
      bytes32 r,
      bytes32 s,
      uint8 v
    )
  {
    require(_signature.length == 65, "Invalid Signature!");
    assembly {
      /*
        First 32 bytes stores the length of the signature

        add(sig, 32) = pointer of sig + 32
        effectively, skips first 32 bytes of signature

        mload(p) loads next 32 bytes starting at the memory address p into memory
        */

      // first 32 bytes, after the length prefix
      r := mload(add(_signature, 32))
      // second 32 bytes
      s := mload(add(_signature, 64))
      // final byte (first byte of the next 32 bytes)
      v := byte(0, mload(add(_signature, 96)))
    }
  }
}
