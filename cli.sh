#!/bin/bash

# Generate r1cs and wasm files. We compile the circuit to get a system of arithmetic equations representing it
# --r1cs: it generates the file multiplier2.r1cs that contains the R1CS constraint system of the circuit in binary format.
# --wasm: it generates the directory multiplier2_js that contains the Wasm code (multiplier2.wasm) and other files needed to generate the witness.
# --sym : it generates the file multiplier2.sym , a symbols file required for debugging or for printing the constraint system in an annotated mode.
# --c : it generates the directory multiplier2_cpp that contains several files (multiplier2.cpp, multiplier2.dat, and other common files for every compiled program like main.cpp, MakeFile, etc) needed to compile the C code to generate the witness.
circom merkle.circom --r1cs --wasm --sym --c

# Computing the witness with given circom output(generate_witness)
node merkle_js/generate_witness.js merkle_js/merkle.wasm input.json witness.wtns

# Use the snarkjs tool to generate and validate a proof for our input.
# Powers of Tau is the first step (circuit trusted setup)
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v
# Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Phase 2(circuit-specific process to generate a proof)
# .zkey file will contain the proving and verification keys together with all phase 2 contributions
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup merkle.r1cs pot12_final.ptau merkle_0000.zkey
snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json


# Generating a Proof
# Once the witness is computed and the trusted setup is already executed, we can generate a zk-proof associated to the circuit and the witness:
# proof.json: it contains the proof.
# public.json: it contains the values of the public inputs and outputs.
snarkjs groth16 prove merkle_0001.zkey witness.wtns proof.json public.json


# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Verifying from smart contract
# snarkjs zkey export solidityverifier merkle_0001.zkey verifier.sol
# snarkjs generatecall
