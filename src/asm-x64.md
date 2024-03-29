Caterwaul x86-64 low-level assembler | Spencer Tipping
Licensed under the terms of the MIT source code license

# Introduction

This assembler provides mnemonics for x86-64 assembly language commands, registers, and addressing modes. It also gives you a way to label and link code segments, though it is not guaranteed
to use the smallest possible jump command. Assemblers are static subclasses of bit-vectors.

    caterwaul.module('asm.x64', ':all', function ($) {
      ($.asm_x64() = $.bit_vector.apply(this, arguments) -then- this.labels /eq.{} -then- this.links /eq.{})

# Static members

These are useful when combined with -using, as they give you easy ways to refer to all x64 general-purpose and SSE registers.

      -se- it /(n[8, 16] *[['r#{x}', x]]   -object -seq)
              /(n[0, 16] *[['xmm#{x}', x]] -object -seq)

# Operand encoding

Operands for most commands are encoded in a ModR/M byte, possibly with an SIB byte and displacement if memory is one of the operands. This library provides a few helpers to generate these
constructs. They are:

    1. rr(op, r1, r2)           Generates a register-register instruction, creating a REX prefix if necessary.
    2. rm(op, r1, r2)           Generates a register-indirect instruction, creating a REX prefix if necessary. No SIB byte.
    3. rd(op, r1, d)            Generates a register-RIP-indirect instruction, creating a REX prefix if necessary. No SIB byte, displacement is a 32-bit vector.
    4. rm8(op, r1, r2, d)       Register-indirect + 8-bit displacement, no SIB byte. Displacement is specified as a bit vector, not a number.
    5. rm32(op, r1, r2, d)      Register-indirect + 32-bit displacement, no SIB byte. Displacement is specified as a bit vector, not a number.
    6. rs(op, r, s, i, b)       Register-indirect with SIB byte, no displacement. s must be 1, 2, 4, or 8.
    7. rs8(op, r, s, i, b, d)   Register-indirect with SIB byte, 8-bit displacement specified as a bit vector.
    8. rs32(op, r, s, i, b, d)  Register-indirect with SIB byte, 32-bit displacement specified as a bit vector.

These methods generally throw errors for invalid argument combinations, or any combinations that would be interpreted in a misleading way. For example, using the rm() form with r2 === rsp dies
because indirecting by %rsp indicates that an SIB byte will be present.

              /wcapture [rax = 0, rcx = 1, rdx = 2, rbx = 3, rsp = 4, rbp = 5, rsi = 6, rdi = 7,
                         al  = 0, cl  = 1, dl  = 2, bl  = 3, ah  = 4, ch  = 5, dh  = 6, bh  = 7,

                         assert(cond, s)         = new Error(s) /raise -unless- cond,

                         rex(r, x, b)            = b01001 << r << x << b |bitwise,
                         maybe_rex(r, x, b)      = r || x || b ? b01001 << r << x << b |bitwise : $.bit_vector(),
                         sib(s, i, b)            = $.bit_vector() << s%2 << i%3 << b%3 |bitwise,

                         rr(op, r1, r2)          = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b11 << r1%3 << r2%3) -bitwise,

                         rd(op, r1, d)           = maybe_rex(r1 & 8, 0, 0)      + op + (b00 << r1%3 << rbp%3) + d[31%0] -bitwise,
                         rm(op, r1, r2)          = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b00 << r1%3 << r2%3)            -bitwise -se- assert(r2     !== rsp, 's/rm(rsp)/rs()/')
                                                                                                                                 -se- assert(r2     !== rbp, 's/rm(rbp)/rd()/')
                                                                                                                                 -se- assert(r2 & 7 !== rbp, 's/rm(r13)/rm8(r13)/'),

                         rm8(op, r1, r2, d)      = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b01 << r1%3 << r2%3) + d[7%0]   -bitwise -se- assert(r2     !== rsp, 's/rm8(rsp)/rs8()/'),
                         rm32(op, r1, r2, d)     = maybe_rex(r1 & 8, 0, r2 & 8) + op + (b10 << r1%3 << r2%3) + d[31%0]  -bitwise -se- assert(r2     !== rsp, 's/rm32(rsp)/rs32()/'),

                         rs(op, r, s, i, b)      = maybe_rex(r & 8, i & 8, b & 8) + op + (b00 << r%3 << rsp%3) + sib(s, i, b)           -bitwise,
                         rs8(op, r, s, i, b, d)  = maybe_rex(r & 8, i & 8, b & 8) + op + (b01 << r%3 << rsp%3) + sib(s, i, b) + d[7%0]  -bitwise,
                         rs32(op, r, s, i, b, d) = maybe_rex(r & 8, i & 8, b & 8) + op + (b10 << r%3 << rsp%3) + sib(s, i, b) + d[31%0] -bitwise]

# Assembler commands

These are encoded minimally as mnemonics for the opcode segment of the command. Many commands use ModR/M and SIB bytes, which are generated using helper methods. Opcodes provide no help in
determining the operands they accept; you need to know this up-front. Further, for unary operators that encode opcode bits in ModR/M, you're responsible for using rr() above to figure out
where the extra opcode bits go and writing them out manually.

In other words, this assembler totally sucks. However, it gives you lots of control about low-level encoding decisions. It also uses a more regular encoding to deal with reversible commands.
For example, movql moves a 64-bit value into its left operand, movqr moves a 64-bit value into its right operand. Normally this relationship is inferred by the assembler, making it sensitive
to operand order. The separate-opcode approach more closely mirrors the hardware model and gives you a more concise variant.

Instructions that are invalid in 64-bit protected mode are not listed here.

              /-$.merge/ wcapture [

                  /* Arithmetic */ addbr = x00, addqr = x01, addbl = x02, addql = x03, addabl = x04, addaql = x05,   orbr  = x08, orqr  = x09, orbl  = x0a, orql  = x0b, orabl  = x0c, oraql  = x0d,
                                   adcbr = x10, adcqr = x11, adcbl = x12, adcql = x13, adcabl = x14, adcaql = x15,   sbbbr = x18, sbbqr = x19, sbbbl = x1a, sbbql = x1b, sbbabl = x1c, sbbaql = x1d,
                                   andbr = x20, andqr = x21, andbl = x22, andql = x23, andabl = x24, andaql = x25,   subbr = x28, subqr = x29, subbl = x2a, subql = x2b, subabl = x2c, subaql = x2d,
                                   xorbr = x30, xorqr = x31, xorbl = x32, xorql = x33, xorabl = x34, xoraql = x35,   cmpbr = x38, cmpqr = x39, cmpbl = x3a, cmpql = x3b, cmpabl = x3c, cmpaql = x3d,

                   /* stack ops */ push(r) = $.asm_x64.maybe_rex(0, 0, r & 8) + b01010 << r%3,  /* test, xchg */ testb = x84, testq = x85, xchgb = x86, xchgq = x87,
                                   pop(r)  = $.asm_x64.maybe_rex(0, 0, r & 8) + b01011 << r%3,                   xchga(r) = $.asm_x64.maybe_rex(0, 0, r & 8) + b10010 << r%3,

                        /* movi */ movi(r) = $.asm_x64.maybe_rex(0, 0, r & 8) + b10111 << r%3,                   movql = x89, movqr = x8b,

                         /* jcc */ j(condition, d) = (x7 << condition%4) + d[7%0],  o = 0x0, no = 0x1, b = 0x2, nb = 0x3, z = 0x4, nz = 0x5, na = 0x6, a = 0x7,
                                                                                    s = 0x8, ns = 0x9, p = 0xa, np = 0xb, l = 0xc, nl = 0xd, ng = 0xe, g = 0xf,

                       /* flags */ sahf = x9e, lahf = x9f, clc = xf8, stc = xf9,                     /* debug/control registers */ movcl = x0f20, movdl = x0f21, movcr = x0f22, movdr = x0f23,
                /* stack frames */ enter(size, level) = xc8 + size[15%0] + level[7%0], leave = xc9,                                rdtsc = x0f31, rdmsr = x0f32, rdpmc = x0f33,
                         /* int */ int(n) = xcd + n[7%0],                                                            /* syscall */ sysen = x0f34, sysex = x0f35,

                        /* SSE2 */ movupsl = x__0f10, movupsr = x__0f11, movupdl = x660f10, movupdr = x660f11,   unpcklps = x0f14, unpcklpd = x660f14,   ucomiss = x__0f2e, comiss = x__0f2f,
                                   movssl  = xf30f10, movssr  = xf30f11, movsdl  = xf20f10, movsdr  = xf20f11,   unpckhps = x0f15, unpckhpd = x660f15,   ucomisd = x660f2e, comisd = x660f2f,

                                   movapsl = x__0f28, movapsr = x__0f29, movapdl = x660f28, movapdr = x660f29,   cvttpsi = x__0f2c, cvttpdi = x660f2c, cvttssi = xf30f2c, cvttsdi = xf20f2c,
                                   cvtpis  = x__0f2a, cvtpid  = x660f2a, cvtsis  = xf30f2a, cvtsid  = xf20f2a,   cvtpsi  = x__0f2d, cvtpdi  = x660f2d, cvtssi  = xf30f2d, cvtsdi  = xf20f2c,

                                   movmskpsl = x__0f50,   sqrtpsl = x__0f51, sqrtssl = xf30f51,   rsqrtpsl = x__0f52,   rcppsl = x__0f53,
                                   movmskpdl = x660f50,   sqrtpdl = x660f51, sqrtsdl = xf20f51,   rsqrtssl = xf30f52,   rcpssl = xf30f53,

                                   andpsl = x__0f54, andnpsl = x__0f55, orpsl = x__0f56, xorpsl = x__0f57,
                                   andpdl = x660f54, andnpdl = x660f55, orpdl = x660f56, xorpdl = x660f57,

                                   addpsl = x__0f58, mulpsl = x__0f59,   cvtpsdl = x__0f5a, cvtpqsl  = x__0f5b,   subpsl = x__0f5c, minpsl = x__0f5d, divpsl = x__0f5e, maxpsl = x__0f5f,
                                   addpdl = x660f58, mulpdl = x660f59,   cvtpdsl = x660f5a, cvtpqdl  = x660f5b,   subpdl = x660f5c, minpdl = x660f5d, divpdl = x660f5e, maxpdl = x660f5f,
                                   addssl = xf30f58, mulssl = xf30f59,   cvtssdl = xf30f5a, cvttpsql = xf30f5b,   subssl = xf30f5c, minssl = xf30f5d, divssl = xf30f5e, maxssl = xf30f5f,
                                   addsdl = xf20f58, mulsdl = xf20f59,   cvtsdsl = xf20f5a,                       subsdl = xf20f5c, minsdl = xf20f5d, divsdl = xf20f5e, maxsdl = xf20f5f,

                        /* cmov */ cmovl(condition) = x0f4 << condition%4, bitwise]});