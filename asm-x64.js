caterwaul.module( 'asm.x64' ,function($) { (function(it) {return $.merge(it, ( (function(o) {for(var r= {} ,i=0,l=o.length,x;
i<l;
 ++i)x=o[i] ,r[x[0] ] =x[1] ;
return r} ) .call(this, ( (function(xs) {var x,x0,xi,xl,xr;
for(var xr=new xs.constructor() ,xi=0,xl=xs.length;
xi<xl;
 ++xi)x=xs[xi] ,xr.push( ( [ ( 'r' + (x) + '' ) ,x] ) ) ;
return xr} ) .call(this, (function(i,u,s) {if( (u-i) *s<=0)return[] ;
for(var r= [] ,d=u-i;
d>0?i<u
:i>u;
i+=s)r.push(i) ;
return r} ) ( (8) , (16) , (1) ) ) ) ) ) , ( (function(o) {for(var r= {} ,i=0,l=o.length,x;
i<l;
 ++i)x=o[i] ,r[x[0] ] =x[1] ;
return r} ) .call(this, ( (function(xs) {var x,x0,xi,xl,xr;
for(var xr=new xs.constructor() ,xi=0,xl=xs.length;
xi<xl;
 ++xi)x=xs[xi] ,xr.push( ( [ ( 'xmm' + (x) + '' ) ,x] ) ) ;
return xr} ) .call(this, (function(i,u,s) {if( (u-i) *s<=0)return[] ;
for(var r= [] ,d=u-i;
d>0?i<u
:i>u;
i+=s)r.push(i) ;
return r} ) ( (0) , (16) , (1) ) ) ) ) ) , (function() {var rax=0,rcx=1,rdx=2,rbx=3,rsp=4,rbp=5,rsi=6,rdi=7,al=0,cl=1,dl=2,bl=3,ah=4,ch=5,dh=6,bh=7,assert=function(cond,s) {;
return!cond&& (function() {throw new Error(s) } ) .call(this) } ,rex=function(r,x,b) {;
return( ( ( (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) ) .push(r) ) .push(x) ) .push(b) } ,maybe_rex=function(r,x,b) {;
return r||x||b? ( ( ( (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) ) .push(r) ) .push(x) ) .push(b) 
:$.bit_vector() } ,sib=function(s,i,b) {;
return $.bit_vector() .push_bits(s,2) .push_bits(i,3) .push_bits(b,3) } ,rr=function(op,r1,r2) {;
return( (maybe_rex(r1&8,0,r2&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push_bits(r1,3) .push_bits(r2,3) ) ) } ,rd=function(op,r1,d) {;
return( ( (maybe_rex(r1&8,0,0) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push_bits(r1,3) .push_bits(rbp,3) ) ) ) .bit_concat( (d) .bit_slice(31,0) ) } ,rm=function(op,r1,r2) {;
return(function(it) {return assert(r2&7!==rbp, 's/rm(r13)/rm8(r13)/' ) ,it} ) .call(this, ( (function(it) {return assert(r2!==rbp, 's/rm(rbp)/rd()/' ) ,it} ) .call(this, ( (function(it) {return assert(r2!==rsp, 's/rm(rsp)/rs()/' ) ,it} ) .call(this, ( ( (maybe_rex(r1&8,0,r2&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push_bits(r1,3) .push_bits(r2,3) ) ) ) ) ) ) ) ) } ,rm8=function(op,r1,r2,d) {;
return(function(it) {return assert(r2!==rsp, 's/rm8(rsp)/rs8()/' ) ,it} ) .call(this, ( ( ( (maybe_rex(r1&8,0,r2&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push_bits(r1,3) .push_bits(r2,3) ) ) ) .bit_concat( (d) .bit_slice(7,0) ) ) ) } ,rm32=function(op,r1,r2,d) {;
return(function(it) {return assert(r2!==rsp, 's/rm32(rsp)/rs32()/' ) ,it} ) .call(this, ( ( ( (maybe_rex(r1&8,0,r2&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push_bits(r1,3) .push_bits(r2,3) ) ) ) .bit_concat( (d) .bit_slice(31,0) ) ) ) } ,rs=function(op,r,s,i,b) {;
return( ( (maybe_rex(r&8,i&8,b&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push_bits(r,3) .push_bits(rsp,3) ) ) ) .bit_concat(sib(s,i,b) ) } ,rs8=function(op,r,s,i,b,d) {;
return( ( ( (maybe_rex(r&8,i&8,b&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push_bits(r,3) .push_bits(rsp,3) ) ) ) .bit_concat(sib(s,i,b) ) ) .bit_concat( (d) .bit_slice(7,0) ) } ,rs32=function(op,r,s,i,b,d) {;
return( ( ( (maybe_rex(r&8,i&8,b&8) ) .bit_concat(op) ) .bit_concat( ( (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push_bits(r,3) .push_bits(rsp,3) ) ) ) .bit_concat(sib(s,i,b) ) ) .bit_concat( (d) .bit_slice(31,0) ) } ;
return{rax:rax,rcx:rcx,rdx:rdx,rbx:rbx,rsp:rsp,rbp:rbp,rsi:rsi,rdi:rdi,al:al,cl:cl,dl:dl,bl:bl,ah:ah,ch:ch,dh:dh,bh:bh,assert:assert,rex:rex,maybe_rex:maybe_rex,sib:sib,rr:rr,rd:rd,rm:rm,rm8:rm8,rm32:rm32,rs:rs,rs8:rs8,rs32:rs32} } ) .call(this) , (function() {var addbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) ,addqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) ,addbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) ,addql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(0) ,addabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) ,addaql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) ,orbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) ,orqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) ,orbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) ,orql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) ,orabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,oraql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,adcbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) ,adcqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) ,adcbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) ,adcql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) ,adcabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) ,adcaql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) ,sbbbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) ,sbbqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) ,sbbbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) ,sbbql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) ,sbbabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) ,sbbaql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) ,andbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) ,andqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) ,andbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) ,andql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) ,andabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) ,andaql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) ,subbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) ,subqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) ,subbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) ,subql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) ,subabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) ,subaql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) ,xorbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) ,xorqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) ,xorbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) ,xorql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) ,xorabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) ,xoraql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) ,cmpbr= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(0) ,cmpqr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(0) ,cmpbl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(0) ,cmpql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(0) ,cmpabl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) ,cmpaql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) ,push=function(r) {;
return($.asm_x64.maybe_rex(0,0,r&8) ) .bit_concat( (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) ) .push_bits(r,3) } ,testb= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) ,testq= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) ,xchgb= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) ,xchgq= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) ,pop=function(r) {;
return($.asm_x64.maybe_rex(0,0,r&8) ) .bit_concat( (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(0) ) .push_bits(r,3) } ,xchga=function(r) {;
return($.asm_x64.maybe_rex(0,0,r&8) ) .bit_concat( (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(1) ) .push_bits(r,3) } ,movi=function(r) {;
return($.asm_x64.maybe_rex(0,0,r&8) ) .bit_concat( (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(0) .push(1) ) .push_bits(r,3) } ,movql= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) ,movqr= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) ,j=function(condition,d) {;
return( ( (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(0) .push_bits(condition,4) ) ) .bit_concat( (d) .bit_slice(7,0) ) } ,o=0x0,no=0x1,b=0x2,nb=0x3,z=0x4,nz=0x5,na=0x6,a=0x7,s=0x8,ns=0x9,p=0xa,np=0xb,l=0xc,nl=0xd,ng=0xe,g=0xf,sahf= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(1) ,lahf= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(1) ,clc= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(1) ,stc= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(1) ,movcl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movcr= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movdr= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,enter=function(size,level) {;
return( ( (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) ) .bit_concat( (size) .bit_slice(15,0) ) ) .bit_concat( (level) .bit_slice(7,0) ) } ,leave= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) ,rdtsc= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,rdmsr= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,rdpmc= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,int=function(n) {;
return( (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) ) .bit_concat( (n) .bit_slice(7,0) ) } ,sysen= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,sysex= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movupsl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movupsr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movupdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,movupdr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,unpcklps= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,unpcklpd= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,ucomiss= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,comiss= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movssl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,movssr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,movsdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,movsdr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,unpckhps= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,unpckhpd= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,ucomisd= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,comisd= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,movapsl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movapsr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movapdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,movapdr= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,cvttpsi= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,cvttpdi= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,cvttssi= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvttsdi= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvtpis= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,cvtpid= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,cvtsis= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvtsid= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvtpsi= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,cvtpdi= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,cvtssi= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvtsdi= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,movmskpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,sqrtpsl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,sqrtssl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,rsqrtpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,rcppsl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,movmskpdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,sqrtpdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,sqrtsdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,rsqrtssl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,rcpssl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,andpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,andnpsl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,orpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,xorpsl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,andpdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,andnpdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,orpdl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,xorpdl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,addpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,mulpsl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,cvtpsdl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,cvtpqsl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,subpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,minpsl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,divpsl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,maxpsl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) ,addpdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,mulpdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,cvtpdsl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,cvtpqdl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,subpdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,minpdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,divpdl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,maxpdl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) ,addssl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,mulssl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvtssdl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvttpsql= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,subssl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,minssl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,divssl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,maxssl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,addsdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,mulsdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cvtsdsl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(0) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,subsdl= (new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,minsdl= (new caterwaul.bit_vector(0) ) .push(1) .push(0) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,divsdl= (new caterwaul.bit_vector(0) ) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,maxsdl= (new caterwaul.bit_vector(0) ) .push(1) .push(1) .push(1) .push(1) .push(1) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push(0) .push(1) .push(0) .push(0) .push(1) .push(1) .push(1) .push(1) ,cmovl=function(condition) {;
return(new caterwaul.bit_vector(0) ) .push(0) .push(0) .push(1) .push(0) .push(1) .push(1) .push(1) .push(1) .push(0) .push(0) .push(0) .push(0) .push_bits(condition,4) } ;
return{addbr:addbr,addqr:addqr,addbl:addbl,addql:addql,addabl:addabl,addaql:addaql,orbr:orbr,orqr:orqr,orbl:orbl,orql:orql,orabl:orabl,oraql:oraql,adcbr:adcbr,adcqr:adcqr,adcbl:adcbl,adcql:adcql,adcabl:adcabl,adcaql:adcaql,sbbbr:sbbbr,sbbqr:sbbqr,sbbbl:sbbbl,sbbql:sbbql,sbbabl:sbbabl,sbbaql:sbbaql,andbr:andbr,andqr:andqr,andbl:andbl,andql:andql,andabl:andabl,andaql:andaql,subbr:subbr,subqr:subqr,subbl:subbl,subql:subql,subabl:subabl,subaql:subaql,xorbr:xorbr,xorqr:xorqr,xorbl:xorbl,xorql:xorql,xorabl:xorabl,xoraql:xoraql,cmpbr:cmpbr,cmpqr:cmpqr,cmpbl:cmpbl,cmpql:cmpql,cmpabl:cmpabl,cmpaql:cmpaql,push:push,testb:testb,testq:testq,xchgb:xchgb,xchgq:xchgq,pop:pop,xchga:xchga,movi:movi,movql:movql,movqr:movqr,j:j,o:o,no:no,b:b,nb:nb,z:z,nz:nz,na:na,a:a,s:s,ns:ns,p:p,np:np,l:l,nl:nl,ng:ng,g:g,sahf:sahf,lahf:lahf,clc:clc,stc:stc,movcl:movcl,movdl:movdl,movcr:movcr,movdr:movdr,enter:enter,leave:leave,rdtsc:rdtsc,rdmsr:rdmsr,rdpmc:rdpmc,int:int,sysen:sysen,sysex:sysex,movupsl:movupsl,movupsr:movupsr,movupdl:movupdl,movupdr:movupdr,unpcklps:unpcklps,unpcklpd:unpcklpd,ucomiss:ucomiss,comiss:comiss,movssl:movssl,movssr:movssr,movsdl:movsdl,movsdr:movsdr,unpckhps:unpckhps,unpckhpd:unpckhpd,ucomisd:ucomisd,comisd:comisd,movapsl:movapsl,movapsr:movapsr,movapdl:movapdl,movapdr:movapdr,cvttpsi:cvttpsi,cvttpdi:cvttpdi,cvttssi:cvttssi,cvttsdi:cvttsdi,cvtpis:cvtpis,cvtpid:cvtpid,cvtsis:cvtsis,cvtsid:cvtsid,cvtpsi:cvtpsi,cvtpdi:cvtpdi,cvtssi:cvtssi,cvtsdi:cvtsdi,movmskpsl:movmskpsl,sqrtpsl:sqrtpsl,sqrtssl:sqrtssl,rsqrtpsl:rsqrtpsl,rcppsl:rcppsl,movmskpdl:movmskpdl,sqrtpdl:sqrtpdl,sqrtsdl:sqrtsdl,rsqrtssl:rsqrtssl,rcpssl:rcpssl,andpsl:andpsl,andnpsl:andnpsl,orpsl:orpsl,xorpsl:xorpsl,andpdl:andpdl,andnpdl:andnpdl,orpdl:orpdl,xorpdl:xorpdl,addpsl:addpsl,mulpsl:mulpsl,cvtpsdl:cvtpsdl,cvtpqsl:cvtpqsl,subpsl:subpsl,minpsl:minpsl,divpsl:divpsl,maxpsl:maxpsl,addpdl:addpdl,mulpdl:mulpdl,cvtpdsl:cvtpdsl,cvtpqdl:cvtpqdl,subpdl:subpdl,minpdl:minpdl,divpdl:divpdl,maxpdl:maxpdl,addssl:addssl,mulssl:mulssl,cvtssdl:cvtssdl,cvttpsql:cvttpsql,subssl:subssl,minssl:minssl,divssl:divssl,maxssl:maxssl,addsdl:addsdl,mulsdl:mulsdl,cvtsdsl:cvtsdsl,subsdl:subsdl,minsdl:minsdl,divsdl:divsdl,maxsdl:maxsdl,cmovl:cmovl} } ) .call(this) ) ,it} ) .call(this, ( ($.asm_x64=function() {;
return( ($.bit_vector.apply(this,arguments) ,this.labels= {} ) ,this.links= {} ) } ) ) ) } ) ;
