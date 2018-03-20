pragma solidity 0.4.19;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./OraclizeAPI.sol";


contract FundraiserRaffle is Ownable, usingOraclize {
  using SafeMath for uint256;
  uint256 public fundraisedAmount = 0;
  uint256 public winnableAmount = 0;
  uint256 public winner;
  uint256 public endDate;
  address public fundraiserAddress;

  address[] public donors;

  enum Stages {
    PreStart,
    Active,
    Complete,
    Finished
  }

  Stages public stage = Stages.PreStart;

  event Donation(
    address indexed from,
    uint256 donation
  );

  event WinnerClaimed(
    address indexed winner,
    uint256 winnings
  );

  event WinnerPicked(
    address indexed winner,
    uint256 winnings
  );

  event FundraiserClaimed(
    address indexed fundraiser,
    uint256 fundraisedAmount
  );

  // only allow certain functions to run at certain stages
  modifier atStage(Stages _stage) {
    require(stage == _stage);
    _;
  }

  // check if fundraising has ended, if so move to next Complete
  modifier checkComplete() {
    if (
      stage == Stages.Active
      && block.timestamp > endDate
    ) {
      enterStage(Stages.Complete);
    }
    _;
  }

  // owner starts as msg.sender
  // ownership is transferred over to fundraiserAddress when startRaffle() called
  function FundraiserRaffle(
    uint256 _endDate,
    address _fundraiserAddress
  )
    public
  {
    require(block.timestamp > endDate);
    require(_fundraiserAddress != address(0));
    require(msg.sender != _fundraiserAddress);
    fundraiserAddress = _fundraiserAddress;
    endDate = _endDate;
  }

  // do not allow anyone to send money to this contract without donate()
  function()
    public
    payable
  {
    revert();
  }

  // allows raffle to start
  // transfers ownership to fundraiser to allow claiming funds when finished
  function startRaffle()
    external
    onlyOwner
    atStage(Stages.PreStart)
    returns (bool)
  {
    enterStage(Stages.Active);
    transferOwnership(fundraiserAddress);
    return true;
  }

  // only way to donate is through this function... fallback will not accept funds
  function donate()
    external
    payable
    checkComplete
    atStage(Stages.Active)
    returns (bool)
  {
    donors.push(msg.sender);
    uint256 winningsIncrement = msg.value.div(2);
    winnableAmount = winnableAmount.add(winningsIncrement);
    fundraisedAmount = fundraisedAmount.add(msg.value.sub(winningsIncrement));
    Donation(msg.sender, msg.value);
  }

  // winner can claim using this after fundraising has ended
  function claimWinnings()
    external
    atStage(Stages.Finished)
    returns (bool)
  {
    require(donors[winner] == msg.sender);
    msg.sender.transfer(winnableAmount);
    WinnerClaimed(msg.sender, winnableAmount);
    return true;
  }

  // fundraiser can claim funds here after fundraising has ended
  function claimFundraisedAmount()
    external
    onlyOwner
    atStage(Stages.Finished)
    returns (bool)
  {
    owner.transfer(fundraisedAmount);
    FundraiserClaimed(owner, fundraisedAmount);
    return true;
  }

  // callback function used to get random winner (uses oraclize)
  function __callback(bytes32 _queryId, string _result, bytes _proof)
    public
    atStage(Stages.Complete)
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
      enterStage(Stages.Finished);
      uint256 _maxRange = donors.length - 1;
      winner = uint(keccak256(_result)) % _maxRange;
      WinnerPicked(donors[winner], winnableAmount);
    }
  }

  // used only after fundraiser complete, anyone can call
  // caller needs to pay for gas costs of generating random number
  // the result is sent to __callback
  function generateRandomNum()
    public
    payable
    checkComplete
    atStage(Stages.Complete)
    returns (bool)
  {
    require(msg.value == 2e5);
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

  // move fundraising on to next stage
  function enterStage(Stages _stage)
    private
  {
    stage = _stage;
  }
}
