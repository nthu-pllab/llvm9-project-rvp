//===-- RISCVInstrInfoP.td - RISC-V 'P' instructions -------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the RISC-V instructions from the extension 'P'
// Packed-SIMD Instructions extension.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Type Profiles.
//===----------------------------------------------------------------------===//

def SDT_RISCVVectorInEltT64_W       : SDTypeProfile<1, 2,  [SDTCisVT<0, v2i32>, 
                                                            SDTCisVT<1, i64>, SDTCisVT<2, v2i32>]>;
def SDT_RISCVVectorInEltB64_W       : SDTypeProfile<1, 2,  [SDTCisVT<0, v2i32>, 
                                                            SDTCisVT<1, v2i32>, SDTCisVT<2, i64>]>;                                                            
def SDT_RISCVVectorExElt64_W        : SDTypeProfile<1, 2,  [SDTCisVT<0, i64>, 
                                                            SDTCisVT<1, i64>, SDTCisVT<2, v2i32>]>;                                          

//===----------------------------------------------------------------------===//
// RISC-V P extension specific DAG Nodes.
//===----------------------------------------------------------------------===//

def VInseretT64_W           : SDNode<"RISCVISD::VINSERTT64_W", SDT_RISCVVectorInEltT64_W>; 
def VInseretB64_W           : SDNode<"RISCVISD::VINSERTB64_W", SDT_RISCVVectorInEltB64_W>;

def VExtractT64_W           : SDNode<"RISCVISD::VEXTRACTT64_W", SDT_RISCVVectorExElt64_W>;
def VExtractB64_W           : SDNode<"RISCVISD::VEXTRACTB64_W", SDT_RISCVVectorExElt64_W>;


//===----------------------------------------------------------------------===//
// P extension Instructions
//===----------------------------------------------------------------------===//

let Predicates = [IsRV64, HasStdExtP] in {

// SIMD add with 32 bits
def ADD32_v2i32 : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I32:$rs1, GPRV64I32:$rs2),
                   [(set GPRV64I32:$dst, (add GPRV64I32:$rs1, GPRV64I32:$rs2))]>,
                   Requires<[IsRV64]> {
                        let AsmString = "kadd32\t$dst, $rs1, $rs2";
                    }

// pack 32-bits
def VINSERTT64_W : Pseudo<(outs GPRV64I32:$dst), (ins GPR:$rs1, GPRV64I32:$rs2),
                   [(set GPRV64I32:$dst, (VInseretT64_W GPR:$rs1, GPRV64I32:$rs2))]>,
                   Requires<[IsRV64]> {
                        let AsmString = "pkbb32\t$dst, $rs1, $rs2";
                    }

def VINSERTB64_W : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I32:$rs1, GPR:$rs2),
                   [(set GPRV64I32:$dst, (VInseretB64_W GPRV64I32:$rs1, GPR:$rs2))]>,
                   Requires<[IsRV64]> {
                        let AsmString = "pktb32\t$dst, $rs1, $rs2";
                    }

// unpack
def VEXTRACTB64_W : Pseudo<(outs GPR:$dst), (ins GPR:$rs1, GPRV64I32:$rs2),
                   [(set GPR:$dst, (VExtractB64_W GPR:$rs1, GPRV64I32:$rs2))]>,
                   Requires<[IsRV64]> {
                        let AsmString = "pkbb32\t$dst, $rs1, $rs2";
                    }

def VEXTRACTT64_W : Pseudo<(outs GPR:$dst), (ins GPR:$rs1, GPRV64I32:$rs2),
                   [(set GPR:$dst, (VExtractT64_W GPR:$rs1, GPRV64I32:$rs2))]>,
                   Requires<[IsRV64]> {
                        let AsmString = "pkbt32\t$dst, $rs1, $rs2";
                    }             

// ----------------------- dot procut ----------------------- 

// Warning : shouldn't be used directly, we use it with accumulation pattern in XXX_COMBINE
def VDOT_SS_B : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I8:$rs1, GPRV64I8:$rs2),
                      [(set GPRV64I32:$dst, (int_riscv_simd_ssdot_v2i32 GPRV64I8:$rs1, GPRV64I8:$rs2))]>,
                      Requires<[IsRV64]> {
                        let AsmString = "smaqa\t$dst, $rs1, $rs2";
                    }

// Warning : shouldn't be used directly, we use it with accumulation pattern in XXX_COMBINE
def VDOT_SU_B : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I8:$rs1, GPRV64I8:$rs2),
                      [(set GPRV64I32:$dst, (int_riscv_simd_sudot_v2i32 GPRV64I8:$rs1, GPRV64I8:$rs2))]>,
                      Requires<[IsRV64]> {
                        let AsmString = "smaqa.su\t$dst, $rs1, $rs2";
                    }

def VDOT64_HW : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I16:$rs1, GPRV64I16:$rs2),
                   [(set GPRV64I32:$dst, (int_riscv_simd_ssdot_i16toi32 GPRV64I16:$rs1, GPRV64I16:$rs2))]>,
                   Requires<[IsRV64]> {
                        let AsmString = "kmada\t$dst, $rs1, $rs2";
                    }    

def VDOT64_HW_KMDA : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I16:$rs1, GPRV64I16:$rs2),
                      [(set GPRV64I32:$dst, (int_riscv_simd_dot_i16toi32 GPRV64I16:$rs1, GPRV64I16:$rs2))]>,
                      Requires<[IsRV64]> {
                        let AsmString = "kmda\t$dst, $rs1, $rs2";
                    }

// combined pattern for dot product with accumulation (kmda + kadd32)
let Constraints = "$dst = $rs0" in {
    def VDOT64_HW_COMBINED : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I32:$rs0, GPRV64I16:$rs1, GPRV64I16:$rs2),
                    [(set GPRV64I32:$dst, (add GPRV64I32:$rs0, (int_riscv_simd_dot_i16toi32 GPRV64I16:$rs1, GPRV64I16:$rs2)))]>,
                    Requires<[IsRV64]> {
    let AsmString = "kmada\t$dst, $rs1, $rs2";
    let mayLoad = 1;
    }
}

// combined pattern for dot product with accumulation (dot product + kadd32)
let Constraints = "$dst = $rs0" in {
    def VDOT_SS_B_COMBINED : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I32:$rs0, GPRV64I8:$rs1, GPRV64I8:$rs2),
                    [(set GPRV64I32:$dst, (add GPRV64I32:$rs0, (int_riscv_simd_ssdot_v2i32 GPRV64I8:$rs1, GPRV64I8:$rs2)))]>,
                    Requires<[IsRV64]> {
    let AsmString = "smaqa\t$dst, $rs1, $rs2";
    let mayLoad = 1;
    }
}

// combined pattern for dot product with accumulation (dot product + kadd32)
let Constraints = "$dst = $rs0" in {
    def VDOT_SU_B_COMBINED : Pseudo<(outs GPRV64I32:$dst), (ins GPRV64I32:$rs0, GPRV64I8:$rs1, GPRV64I8:$rs2),
                    [(set GPRV64I32:$dst, (add GPRV64I32:$rs0, (int_riscv_simd_sudot_v2i32 GPRV64I8:$rs1, GPRV64I8:$rs2)))]>,
                    Requires<[IsRV64]> {
    let AsmString = "smaqa.su\t$dst, $rs1, $rs2";
    let mayLoad = 1;
    }
}

}