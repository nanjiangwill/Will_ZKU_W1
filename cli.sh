#!/bin/bash

# Generate r1cs and wasm
circom merkle.circom --r1cs --wasm --sym --c

# Computing the witness with WebAssembly
node merkle_js/generate_witness.js merkle_js/merkle.wasm input.json witness.wtns

#Powers of Tau
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup merkle.r1cs pot12_final.ptau merkle_0000.zkey
snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json

# Generating a Proof
snarkjs groth16 prove merkle_0001.zkey witness.wtns proof.json public.json


# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Verifying from smart contract
# snarkjs zkey export solidityverifier merkle_0001.zkey verifier.sol
# snarkjs generatecall
