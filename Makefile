.PHONY: gas-benchmark
gas-benchmark:
	dapp test --verbosity=2 --match="testGas" > .gas-benchmark

