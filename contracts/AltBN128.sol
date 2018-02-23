pragma solidity ^0.4.13;
pragma experimental ABIEncoderV2;

contract AltBN128 {
  struct G1 {
    uint x;
    uint y;
  }
  G1 g1 = G1(1,2);

  struct G2 {
    uint xb;
    uint xa;
    uint yb;
    uint ya;
  }
  G2 g2 = G2(
    11559732032986387107991004021392285783925812861821192530917403151452391805634,
    10857046999023057135944570762232829481370756359578518086990519993285655852781,
    4082367875863433681332203403145435568316851327593401208105741076214120093531,
    8495653923123431417604973247489272438418190587263600148770280649306958101930
  );

  uint256 prime = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
  uint256 pminus = 21888242871839275222246405745257275088696311157297823662689037894645226208582;
  uint256 pplus = 21888242871839275222246405745257275088696311157297823662689037894645226208584;

  function modPow(uint256 base, uint256 exponent, uint256 modulus) public returns (uint256) {
    uint256[6] memory input;
    input[0] = 32;
    input[1] = 32;
    input[2] = 32;
    input[3] = base;
    input[4] = exponent;
    input[5] = modulus;
    uint256[1] memory result;
    assembly {
      if iszero(call(not(0), 0x05, 0, input, 0xc0, result, 0x20)) {
        revert(0, 0)
      }
    }
    return result[0];
  }

  function sumPoints(G1[] points) public returns (G1) {
    G1 memory current = points[0];
    for (uint i=1; i<points.length; i++) {
      current = addPoints(current, points[i]);
    }
    return current;
  }

  function addPoints(G1 a, G1 b) public returns (G1) {
    uint256[4] memory input;
    input[0] = a.x;
    input[1] = a.y;
    input[2] = b.x;
    input[3] = b.y;
    uint[2] memory result;
    assembly {
      if iszero(call(not(0), 0x06, 0, input, 0x80, result, 0x40)) {
        revert(0, 0)
      }
    }
    return G1(result[0], result[1]);
  }

  function scalarMultiply(G1 point, uint256 scalar) public returns(G1) {
    uint256[3] memory input;
    input[0] = point.x;
    input[1] = point.y;
    input[2] = scalar;
    uint[2] memory result;
    assembly {
      if iszero(call(not(0), 0x07, 0, input, 0x60, result, 0x40)) {
        revert(0, 0)
      }
    }
    return G1(result[0], result[1]);
  }

  function pairingCheck(G1 a, G2 x, G1 b, G2 y) public returns (bool) {
    //returns e(a,x) == e(b,y)
    uint256[12] memory input;
    input[0] = a.x;
    input[1] = a.y;
    input[2] = x.xb;
    input[3] = x.xa;
    input[4] = x.yb;
    input[5] = x.ya;
    input[6] = b.x;
    input[7] = prime - b.y;
    input[8] = y.xb;
    input[9] = y.xa;
    input[10] = y.yb;
    input[11] = y.ya;
    uint[1] memory result;
    assembly {
      if iszero(call(not(0), 0x08, 0, input, 0x180, result, 0x20)){
          revert(0, 0)
      }
    }
    return result[0]==1;
  }
  function hashToG1(bytes b) public returns (G1) {
    uint x = 0;
    while (true) {
      uint256 hx = uint256(keccak256(b,byte(x)))%prime;
      uint256 px = (modPow(hx,3,prime) + 3);
      if (modPow(px, pminus/2, prime) == 1) {
        uint256 py = modPow(px, pplus/4, prime);
        if (uint(keccak256(b,byte(255)))%2 == 0)
          return G1(hx,py);
        else
          return G1(hx,prime-py);
      } else {
        x++;
      }
    }
  }
  function hash(bytes b) public returns (uint,uint) {
    G1 memory h = hashToG1(b);
    return (h.x, h.y);
  }
  function checkSignature(bytes data, G1 sig, G2 pubKey) public returns (bool) {
    return pairingCheck(sig, g2, hashToG1(data), pubKey);
  }
  function verifyMultiSignature(bytes data, G1 sig, G2 aggPubKey, G1[] pairKeys) public returns (bool) {
    return pairingCheck(sumPoints(pairKeys), g2, g1, aggPubKey) &&
           checkSignature(data, sig, aggPubKey);
  }
  function SageTest(bytes message) returns (bool) {
    G2 memory pk = G2(
      12703405598006979409108671416960902338538868397248453921759384556929622558257,
      142094823562702583669092464225103219873886198373818886253774429994499461119,
      21792722069934396490667258760160363541978805696356802531479377933366930348185,
      10504771741599673449168779439288281645955231116910341346670256599842843491846
    );
    uint k = 123456789;
    G1 memory h = hashToG1(message);
    G1 memory sig = scalarMultiply(h,k);
    return pairingCheck(sig, g2, h, pk);
  }
}
