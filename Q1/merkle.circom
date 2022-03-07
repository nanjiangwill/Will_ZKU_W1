pragma circom 2.0.0;

// include "mimcsponge.circom";
include "/Users/willjiang/circomlib/circuits/mimcsponge.circom";

template Merekle(N) {
    signal input leaves[N];
    signal output out;
    
    component mimc = MiMCSponge(N, 220, 1);
    
    for (var i = 0; i < N; i++) {
        mimc.ins[i] <== leaves[i];
    }
    mimc.k <== 0;

    out <== mimc.outs[0];
 }

component main = Merekle(8);

