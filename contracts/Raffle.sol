pragma solidity 0.4.19;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./OraclizeAPI.sol";


contract FundraiserRaffle is Ownable, usingOraclize {
  using SafeMath for uint256;
  uint256 public fundraisedAmount = 0;
  uint256 public winnableAmount = 0;
  uint256 public fundraiserGoal;
  uint256 public randomWinner;

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

  modifier atStage(Stages _stage) {
    require(stage == _stage);
    _;
  }

  function FundraiserRaffle(uint256 _fundraiserGoal)
    public
  {
    fundraiserGoal = _fundraiserGoal;
  }

  // do not allow anyone to send money to this contract without donate()
  function()
    public
    payable
  {
    revert();
  }

  function startRaffle()
    external
    onlyOwner
    atStage(Stages.PreStart)
    returns (bool)
  {
    enterStage(Stages.Active);
    return true;
  }

  function donate()
    external
    payable
    atStage(Stages.Active)
    returns (bool)
  {
    donors.push(msg.sender);
    uint256 winningsIncrement = msg.value.div(2);
    winnableAmount = winnableAmount.add(winningsIncrement);
    fundraisedAmount = msg.value.sub(winnableAmount);
    Donation(msg.sender, msg.value);
    if (fundraisedAmount.add(winnableAmount) > fundraiserGoal) {
      enterStage(Stages.Complete);
    }
  }

  function claimWinnings()
    external
    atStage(Stages.Finished)
    returns (bool)
  {
    require(donors[randomWinner] == msg.sender);
    msg.sender.transfer(winnableAmount);
    WinnerClaimed(msg.sender, winnableAmount);
    return true;
  }

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
      uint256 _maxRange = donors.length;
      randomWinner = uint(keccak256(_result)) % _maxRange;
      WinnerPicked(donors[randomWinner], winnableAmount);
    }
  }

  // used only after fundraiser complete, anyone can call
  // caller needs to pay for gas costs of generating random number
  function generateRandomNum()
    public
    payable
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

  function enterStage(Stages _stage)
    private
  {
    stage = _stage;
  }
}
