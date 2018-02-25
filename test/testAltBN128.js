/*
function sumPoints(G1[] points) internal returns (G1) {
  G1 memory current = points[0];
  for (uint i=1; i<points.length; i++) {
    current = addPoints(current, points[i]);
  }
  return current;
}
function hash(bytes b) public returns (uint,uint) {
  G1 memory h = hashToG1(b);
  return (h.x, h.y);
}
function checkSignature(bytes data, G1 sig, G2 pubKey) internal returns (bool) {
  return pairingCheck(sig, g2, hashToG1(data), pubKey);
}
function verifyMultiSignature(bytes data, G1 sig, G2 aggPubKey, G1[] pairKeys) internal returns (bool) {
  return pairingCheck(sumPoints(pairKeys), g2, g1, aggPubKey) &&
         checkSignature(data, sig, aggPubKey);
}
function SageTest(bytes message) public returns (bool) {
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


function checkSig(
  bytes message,
  uint sigX, uint sigY,
  uint pkXi, uint pkXr, uint pkYi, uint pkYr) public returns (bool)
{
  return checkSignature(message, G1(sigX,sigY), makeG2(pkXi,pkXr,pkYi,pkYr));
}
function checkMultiSig(
  bytes message,
  uint sigX, uint sigY,
  uint pkXi, uint pkXr, uint pkYi, uint pkYr,
  uint[] pairX, uint[] pairY) public returns (bool)
{
  assert(pairX.length == pairY.length);
  G1[] memory pks = new G1[](pairX.length);
  for (uint i=0; i<pairX.length; i++) {
    pks[i] = makeG1(pairX[i],pairY[i]);
  }
  return verifyMultiSignature(message, makeG1(sigX,sigY), makeG2(pkXi,pkXr,pkYi,pkYr), pks);
}
function testMulti() public returns (bool) {
    uint[] memory pairX = new uint[](2);
    pairX[0] = 9121282642809701931333593728297233225556711250127745709186816755779879923737;
    pairX[1] = 19430493116922072356830709910231609246608721301711710668649991649389881488730;
    uint[] memory pairY = new uint[](2);
    pairY[0] = 8783642022119951289582979607207867126556038468480503109520224385365741455513;
    pairY[1] = 4110959498627045907440291871300490703579626657177845575364169615082683328588;
    return checkMultiSig("test",
    3879779628276216629228885668678419761101278770282689216872789981355377228865,5899128309307982540328776489413185892969661962670902352663678096882392449410,
    992681490776324354202397263392574385761713709094829624534898995154831070891,
    1305187323429665276225105765715151559212072388663597666681036484692768456251,
    17666574447146782318673097502150892916522088334833460488250104240828747929194,
    21135417369703474382124573170963634207503570334778660361646524490596958122804,pairX,pairY);
}



*/
