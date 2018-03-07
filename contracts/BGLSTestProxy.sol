
pragma solidity ^0.4.17;

import "contracts/BGLS.sol";

contract BGLSTestProxy is BGLS {
  function pairingCheckTrivial() public returns (bool) {
    return pairingCheck(g1,g2,g1,g2);
  }
  function pairingCheckMult() public returns (bool) {
    return pairingCheck(scalarMultiply(g1,12345),g2,scalarMultiply(g1,12345),g2);
  }
  event PrintG1(string t, uint x, uint y);

  function addTest() public returns (bool) {
    G1 memory a = G1(
      9121282642809701931333593728297233225556711250127745709186816755779879923737,
      8783642022119951289582979607207867126556038468480503109520224385365741455513);
    G1 memory b = G1(
      19430493116922072356830709910231609246608721301711710668649991649389881488730,
      4110959498627045907440291871300490703579626657177845575364169615082683328588);
    G1 memory ab = addPoints(a,b);
    G1 memory expected = G1(
      17981918273786386398769813244173616322667195802888989780909050086192926768907,
      18658404630663819378315425423756597890713010608083111245835977740656931644247);
    return ab.x == expected.x && ab.y == expected.y;
  }
  function scalarTest() public returns (bool) {
    G1 memory expected = G1(
      11404940445424363337823423808411232433223590477377068719858726746225925918890,
      2424505913866680143139332783087422983475325405994502385033744924144562639386
    );
    G1 memory res = scalarMultiply(g1,12345);
    return res.x == expected.x && res.y == expected.y;
  }
  function hashToG1Test() public returns (bool) {
    return false;
  }

  function testSumPoints() public returns (bool) {
    G1[] memory points = new G1[](5);
    points[0] = G1(
      9121282642809701931333593728297233225556711250127745709186816755779879923737,
      8783642022119951289582979607207867126556038468480503109520224385365741455513
    );
    points[1] = G1(
      19430493116922072356830709910231609246608721301711710668649991649389881488730,
      4110959498627045907440291871300490703579626657177845575364169615082683328588
    );
    points[2] = G1(
      20422461965303760684972432833393275482011872214285431434762613176151735978626,
      4340414105609005319657729201597518376025644764079088797074616044782247204946
    );
    points[3] = G1(
      298572075162454679163670333497954782367165699328351139754869100063308445382,
      19406526149564276287084583577153409216667341395977223898932369699699605058292
    );
    points[4] = G1(
      13617110937608119725159715497522173305174557569388165671955816638318382445127,
      5989220236822003292279415228814579004737160217409816506111930966995235750604
    );
    //G1 memory p1 = sumPoints(points, hex"01");
    //G1 memory p2 = sumPoints(points, hex"02");
    //G1 memory p3 = sumPoints(points, hex"04");
    //G1 memory p4 = sumPoints(points, hex"08");
    //G1 memory p5 = sumPoints(points, hex"10");
    //G1 memory p12 = sumPoints(points, hex"03");
    //G1 memory p13 = sumPoints(points, hex"05");
    //G1 memory p23 = sumPoints(points, hex"06");
    G1 memory sumall = sumPoints(points, hex"0f");
    //G1 memory add12 = addPoints(points[0], points[1]);
    //G1 memory add13 = addPoints(points[0], points[2]);
    //G1 memory add23 = addPoints(points[1], points[2]);
    G1 memory addall = addPoints(points[0], addPoints(points[1], addPoints(points[2], points[3])));
    //PrintG1("p1",p1.x, p1.y);
    //PrintG1("points[0]", points[0].x, points[0].y);
    //PrintG1("p2",p2.x, p2.y);
    //PrintG1("points[1]", points[1].x, points[1].y);
    //PrintG1("p3",p3.x, p3.y);
    //PrintG1("points[2]", points[2].x, points[2].y);
    //PrintG1("p4",p4.x, p4.y);
    //PrintG1("points[3]", points[3].x, points[3].y);
    //PrintG1("p5",p5.x, p5.y);
    //PrintG1("points[4]", points[4].x, points[4].y);
    //PrintG1("p12",p12.x, p12.y);
    //PrintG1("add12", add12.x, add12.y);
    //PrintG1("p13",p13.x, p13.y);
    //PrintG1("add13", add13.x, add13.y);
    //PrintG1("p23",p23.x, p23.y);
    //PrintG1("add23", add23.x, add23.y);
    PrintG1("sumall", sumall.x, sumall.y);
    PrintG1("addall", addall.x, addall.y);
    return sumall.x == addall.x && sumall.y == addall.y;
      //points[0].x == p1.x && points[0].y == p1.y &&
      //points[1].x == p2.x && points[1].y == p2.y &&
      //points[2].x == p3.x && points[2].y == p3.y &&
      //points[3].x == p4.x && points[3].y == p4.y &&
      //points[4].x == p5.x && points[4].y == p5.y &&
      //p12.x == add12.x && p12.y == add12.y &&
      //p13.x == add13.x && p13.y == add13.y &&
      //p23.x == add23.x && p23.y == add23.y &&
  }



  function testSignature(uint[] values) public returns (bool) {
    uint privKey = 123456789;
    G2 memory pubKey = G2(
      12703405598006979409108671416960902338538868397248453921759384556929622558257,
      142094823562702583669092464225103219873886198373818886253774429994499461119,
      21792722069934396490667258760160363541978805696356802531479377933366930348185,
      10504771741599673449168779439288281645955231116910341346670256599842843491846
    );
    G1 memory h = hashToG1(values);
    G1 memory sig = scalarMultiply(h,privKey);
    return pairingCheck(sig, g2, h, pubKey);
  }
}
