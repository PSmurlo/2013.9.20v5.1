function [CB]=evenCB(CBstrings,qH,qW)
CB.Strings=CBstrings;
CB.Tables=CB.Strings./8;
CB.CBqH=CB.Tables./qW;
CB.Strings(mod(CB.CBqH,1)~=0)=[]; %remove if not an integer
CB.Tables(mod(CB.CBqH,1)~=0)=[]; %remove if not an integer
CB.CBqH(mod(CB.CBqH,1)~=0)=[]; %remove if not an integer

CB.num=qH*qW*4./CB.Strings;%(1./CBqH)*qH;
CB.qH=qH;
CB.qW=qW;