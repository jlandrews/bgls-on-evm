

const BGLS = artifacts.require("BGLS");
const BGLSTestProxy = artifacts.require("BGLSTestProxy");

contract("BGLS", async (accounts) =>  {
  let bgls;
  let bglsTest;
  beforeEach(async () => {
    bgls = await BGLS.new();
    bglsTest = await BGLSTestProxy.new();
  })
  it("should verify trivial pairing", async () => {
    assert(await bglsTest.pairingCheckTrivial.call());
  });
  it("should verify scalar multiple pairing", async () => {
    assert(await bglsTest.pairingCheckMult.call());
  });
  it("should add points correctly", async () => {
    assert(await bglsTest.addTest.call());
  })
  it("should do scalar multiplication correctly", async () => {
    assert(await bglsTest.scalarTest.call());
  })
  it("should verify a simple signature correctly", async () => {
    assert(await bglsTest.testSignature.call([12345,54321,10101,20202,30303]));
  })
  it("should sum points correctly", async () => {
    assert(await bglsTest.testSumPoints.call());
  })
})
