pragma solidity 0.4.19;

import "./OraclizeAPI.sol";


// fundraiser interface
contract Fundraiser {
  function setWinner(string _randomWinner)
    external
    returns (bool)
  {}
}


contract RandomNumberGenerator is usingOraclize {
  Fundraiser public fundraiser;

  modifier onlyFundraiser() {
    require(msg.sender == address(fundraiser));
    _;
  }

  // fundraiser contract set in constructor, cannot be changed later
  function RandomNumberGenerator(address _fundraiserAddress)
    public
  {
    require(_fundraiserAddress != address(0));
    // ensure that address is a contract
    uint256 _size;
    assembly { _size := extcodesize(_fundraiserAddress) }
    require(_size > 0);
    fundraiser = Fundraiser(_fundraiserAddress);
  }

  // callback function used to get random winner (uses oraclize)
  function __callback(bytes32 _queryId, string _result, bytes _proof)
    public
  {
    require(msg.sender == oraclize_cbAddress());
    // if 0 proof, verification failed...
    if (oraclize_randomDS_proofVerify__returnCode(
      _queryId,
      _result,
      _proof) != 0
    ) {
      revert();
    } else {
      fundraiser.setWinner(_result);
    }
  }

  // used only after fundraiser complete, anyone can call
  // caller needs to pay for gas costs of generating random number
  // the result is sent to __callback
  function generateRandomNum()
    external
    payable
    onlyFundraiser
    returns (bool)
  {
    require(msg.value >= 2e5);
    oraclize_setProof(proofType_Ledger);
    uint256 _randomByteCount = 4;
    uint256 _delay = 0;
    uint256 _callbackGas = 2e5;
    oraclize_newRandomDSQuery(
      _delay,
      _randomByteCount,
      _callbackGas
    );
    return true;
  }
}
