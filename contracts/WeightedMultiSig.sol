pragma solidity ^0.4.17;

import "contracts/AltBN128.sol";

contract WeightedMultiSig is AltBN128 {
  G1[] pairKeys;
  uint[] weights;
  uint threshold;
  uint state;

  function WeightedMultiSig(uint[] pairKeyX, uint[] pairKeyY, uint[] _weights, uint _threshold) {
    setStateInternal(pairKeyX, pairKeyY, _weights, _threshold);
  }
  function updateState(uint numSigners, bytes newState, bytes signers,
    uint sigX, uint sigY,
    uint pkXi, uint pkXr, uint pkYi, uint pkYr) public {
      require(checkSig(signers, newState, sigX, sigY, pkXi, pkXr, pkYi, pkYr));
      require(newState.length == 96*numSigners + 64);
      uint _state = uint(newState[0:32]);
      require(_state > state);
      uint _threshold = uint(newState[32:64]);
      uint[] pairKeyX = new uint[](numSigners);
      uint[] pairKeyY = new uint[](numSigners);
      uint[] _weights = new uint[](numSigners);
      for (uint i = 0; i < numSigners; i++) {
        uint x = 64 + i*96
        pairKeyX[i] = newState[x:x+32];
        pairKeyY[i] = newState[x+32:x+64];
        _weights[i] = newState[x+64:x+96];
      }
      setStateInternal(pairKeyX, pairKeyY, _weights, _threshold);

      //parse newState into 3n+1 uints, arrange into 3 arrays and call setStateInternal
    }
  function setStateInternal(uint[] pairKeyX, uint[] pairKeyY, uint[] _weights, uint _threshold) internal {
    assert(pairKeyX.length == pairKeyY.length && pairKeyX.length == _weights.length);
    G1[] storage _pairKeys = new G1[](pairKeyX.length);
    for (uint i = 0; i < pairKeyX.length; i++) {
      _pairKeys.push(G1(pairKeyX[i], pairKeyY[i]));
    }
    pairKeys = _pairKeys;
    weights = _weights;
    threshold = _threshold;
    state += 1;
  }

  function chkBit(bytes b, uint x) public pure returns (bool) {
    return uint(b[x/8])&(uint(1)<<(x%8)) != 0;
  }

  function addKey(uint x, uint y) public {
    pairKeys.push(G1(x,y));
    weights.push(1);
    threshold = weights.length/2 + 1;
  }
  function isQuorum(bytes signers) internal view returns (bool){
    uint weight = 0;
    for (uint i = 0; i < weights.length; i++) {
      if (chkBit(signers,i)) weight += weights[i];
    }
    return weight >= threshold;
  }
  function checkAggKey(bytes signers, G2 aggKey) internal returns (bool) {
    G1 memory acc = G1(0,0);
    for (uint i = 0; i < weights.length; i++) {
      if (chkBit(signers,i)) acc = addPoints(acc, pairKeys[i]);
    }
    return pairingCheck(acc,g2,g1,aggKey);
  }
  function checkSig(bytes signers, bytes message,
    uint sigX, uint sigY,
    uint pkXi, uint pkXr, uint pkYi, uint pkYr) public returns (bool) {
      G2 memory aggKey = G2(pkXi, pkXr, pkYi, pkYr);
      G1 memory sig = G1(sigX, sigY);
      return isQuorum(signers) && checkAggKey(signers, aggKey) && checkSignature(message, sig, aggKey);
    }
}
