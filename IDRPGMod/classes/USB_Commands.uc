class USB_Commands extends Actor
	abstract;

static function byte GreaterNumericValueOfStrings(string S, string SS)
{
	local bool bInvert,bNegative,bNegativeS;
	local int i,l,m,n;
	local string SSS,SSSS;

	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
		bNegative=True;
	}

	if(Left(SS,1)~="-")
	{
		SS=Mid(SS,1);
		bNegativeS=True;
	}

	S=FixFloatString(S);
	SS=FixFloatString(SS);

	if(bNegative && !(S~="0"))
	{
		S="-"$S;
	}

	if(bNegativeS && !(SS~="0"))
	{
		SS="-"$SS;
	}

	if(S~=SS)
	{
		return 0;
	}
	else if(Left(S,1)~="-" && Left(SS,1)~="-")
	{
		S=Mid(S,1);
		SS=Mid(SS,1);
		bInvert=True;
	}
	else if(Left(S,1)~="-")
	{
		return 2;
	}
	else if(Left(SS,1)~="-")
	{
		return 1;
	}

	if(bInvert)
	{
		i=GreaterNumericValueOfStrings(S,SS);

		if(i==1)
		{
			return 2;
		}
		else if(i==2)
		{
			return 1;
		}

		return iEval(i==0,0,iEval(i==1,2,iEval(i==2,1,0)));
	}

	i=InStr(S,".");
	l=InStr(SS,".");

	if(i!=-1 || l!=-1)
	{
		if(i!=-1)
		{
			SSS=Left(S,i);
			SSSS=Mid(S,i+1);
			m=iEval((i==-1 || SSSS~="0"),0,Len(SSSS));
			S=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		if(l!=-1)
		{
			SSS=Left(SS,l);
			SSSS=Mid(SS,l+1);
			n=iEval((l==-1 || SSSS~="0"),0,Len(SSSS));
			SS=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		while(m<n)
		{
			S$="0";
			m++;
		}

		while(n<m)
		{
			SS$="0";
			n++;
		}

		if(S~=SS)
		{
			return 0;
		}

		return GreaterNumericValueOfStrings(S,SS);
	}

	if(Len(S)>Len(SS))
	{
		return 1;
	}
	else if(Len(S)<Len(SS))
	{
		return 2;
	}

	for(i=0;i<Len(S);i++)
	{
		l=GetNumericValueFromString(Mid(S,i,1));
		m=GetNumericValueFromString(Mid(SS,i,1));

		if(l>m)
		{
			return 1;
		}
		else if(l<m)
		{
			return 2;
		}
	}

	return 0;
}

static function string SubtractNumericValuesFromStrings(string S, string SS, optional int Z)
{
	local int i,l,m,n;
	local bool bNegative,bNegativeS;
	local string SSS,SSSS;

	Z=Clamp(Z,0,100);

	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
		bNegative=True;
	}

	if(Left(SS,1)~="-")
	{
		SS=Mid(SS,1);
		bNegativeS=True;
	}

	S=FixFloatString(S);
	SS=FixFloatString(SS);

	if(S~=SS)
	{
		return "0";
	}
	else if(S~="0")
	{
		return Eval(bNegativeS,ReduceFloatString(SS,Z),Eval(ReduceFloatString(SS,Z)~="0",SS,"-"$ReduceFloatString(SS,Z)));
	}
	else if(SS~="0")
	{
		return Eval(!bNegative,ReduceFloatString(S,Z),Eval(ReduceFloatString(S,Z)~="0",S,"-"$ReduceFloatString(S,Z)));
	}

	if(!bNegative && bNegativeS)
	{
		return AddNumericValuesFromStrings(S,SS,Z);
	}
	else if(bNegative && !bNegativeS)
	{
		SSS=AddNumericValuesFromStrings(S,SS,Z);
		return Eval(SSS~="0","0",Eval(Left(SSS,1)~="-","","-")$SSS);
	}
	else if(bNegative && bNegativeS)
	{
		return SubtractNumericValuesFromStrings(SS,S,Z);
	}
	else if(GreaterNumericValueOfStrings(S,SS)==2)
	{
		SSS=SubtractNumericValuesFromStrings(SS,S,Z);
		return Eval(SSS~="0","0",Eval(Left(SSS,1)~="-","","-")$SSS);
	}

	i=InStr(S,".");
	l=InStr(SS,".");

	if(i!=-1 || l!=-1)
	{
		if(i!=-1)
		{
			SSS=Left(S,i);
			SSSS=Mid(S,i+1);
			m=iEval((i==-1 || SSSS~="0"),0,Len(SSSS));
			S=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		if(l!=-1)
		{
			SSS=Left(SS,l);
			SSSS=Mid(SS,l+1);
			n=iEval((l==-1 || SSSS~="0"),0,Len(SSSS));
			SS=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		while(m<n)
		{
			S$="0";
			m++;
		}

		while(n<m)
		{
			SS$="0";
			n++;
		}

		if(S~=SS)
		{
			return "0";
		}

		SSS=SubtractNumericValuesFromStrings(S,SS,Z);

		while(Len(SSS)<=n)
		{
			SSS="0"$SSS;
		}

		SSS=Left(SSS,Len(SSS)-n)$"."$Mid(SSS,Len(SSS)-n);

		if(Z>=0)
		{
			SSS=ReduceFloatString(SSS,Z);
		}

		return FixFloatString(SSS);
	}

	for(i=0;i<Len(SS);i++)
	{
		l=GetNumericValueFromString(Mid(S,Len(S)-i-1,1));
		m=GetNumericValueFromString(Mid(SS,Len(SS)-i-1,1));
		l-=m+n;
		n=iEval(l>=0,0,iLeft(9+Abs(l),1));
		l=iEval(l>=0,l%10,(10-(Abs(l)%10))%10);
		S=Left(S,Len(S)-i-1)$l$Mid(S,Len(S)-i);
	}

	while(n>0 && i<Len(S))
	{
		l=GetNumericValueFromString(Mid(S,Len(S)-i-1,1));
		l-=n;
		n=iEval(l>=0,0,iLeft(9+Abs(l),1));
		l=iEval(l>=0,l%10,(10-(Abs(l)%10))%10);
		S=Left(S,Len(S)-i-1)$l$Mid(S,Len(S)-i);
		i++;
	}

	while(Left(S,1)~="0" && Len(S)>1)
	{
		S=Mid(S,1);
	}

	return GetNumericStringValueFromString(S);
}

static function string AddNumericValuesFromStrings(string S, string SS, optional int Z)
{
	local int i,l,m,n;
	local bool bNegative,bNegativeS;
	local string SSS,SSSS;

	Z=Clamp(Z,0,100);

	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
		bNegative=True;
	}

	if(Left(SS,1)~="-")
	{
		SS=Mid(SS,1);
		bNegativeS=True;
	}

	S=FixFloatString(S);
	SS=FixFloatString(SS);

	if(S~="0")
	{
		return Eval(!bNegativeS,ReduceFloatString(SS,Z),Eval(ReduceFloatString(SS,Z)~="0",SS,"-"$ReduceFloatString(SS,Z)));
	}
	else if(SS~="0")
	{
		return Eval(!bNegative,ReduceFloatString(S,Z),Eval(ReduceFloatString(S,Z)~="0",S,"-"$ReduceFloatString(S,Z)));
	}

	if(bNegative && !bNegativeS)
	{
		return SubtractNumericValuesFromStrings(SS,S,Z);
	}
	else if(!bNegative && bNegativeS)
	{
		SSS=SubtractNumericValuesFromStrings(SS,S,Z);
		return Eval(SSS~="0","0",Eval(Left(SSS,1)~="-","","-")$SSS);
	}
	else if(bNegative && bNegativeS)
	{
		SSS=AddNumericValuesFromStrings(S,SS,Z);
		return Eval(SSS~="0","0",Eval(Left(SSS,1)~="-","","-")$SSS);
	}

	i=InStr(S,".");
	l=InStr(SS,".");

	if(i!=-1 || l!=-1)
	{
		if(i!=-1)
		{
			SSS=Left(S,i);
			SSSS=Mid(S,i+1);
			m=iEval((i==-1 || SSSS~="0"),0,Len(SSSS));
			S=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		if(l!=-1)
		{
			SSS=Left(SS,l);
			SSSS=Mid(SS,l+1);
			n=iEval((l==-1 || SSSS~="0"),0,Len(SSSS));
			SS=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		while(m<n)
		{
			S$="0";
			m++;
		}

		while(n<m)
		{
			SS$="0";
			n++;
		}

		SSS=AddNumericValuesFromStrings(S,SS,Z);

		while(Len(SSS)<=n)
		{
			SSS="0"$SSS;
		}

		SSS=Left(SSS,Len(SSS)-n)$"."$Mid(SSS,Len(SSS)-n);
		SSS=ReduceFloatString(SSS,Z);
		return FixFloatString(SSS);
	}

	if(Len(SS)>Len(S))
	{
		Exchange(S,SS);
	}

	for(i=0;i<Len(SS);i++)
	{
		l=GetNumericValueFromString(Mid(S,Len(S)-i-1,1));
		m=GetNumericValueFromString(Mid(SS,Len(SS)-i-1,1));
		l+=m+n;
		n=iEval(l<10,0,iLeft(l,iLen(l)-1));
		l=l%10;
		S=Left(S,Len(S)-i-1)$l$Mid(S,Len(S)-i);
	}

	while(n>0 && i<Len(S))
	{
		l=GetNumericValueFromString(Mid(S,Len(S)-i-1,1));
		l+=n;
		n=iEval(l<10,0,iLeft(l,iLen(l)-1));
		l=l%10;
		S=Left(S,Len(S)-i-1)$l$Mid(S,Len(S)-i);
		i++;
	}

	if(n>0)
	{
		S=n$S;
	}

	return GetNumericStringValueFromString(S);
}

static function string MultiplyNumericValuesFromStrings(string S, string SS, optional int Z)
{
	local int i,l,m,n,k;
	local bool bNegative,bNegativeS;
	local string SSS,SSSS;

	Z=Clamp(Z,0,100);

	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
		bNegative=True;
	}

	if(Left(SS,1)~="-")
	{
		SS=Mid(SS,1);
		bNegativeS=True;
	}

	if((bNegative && !bNegativeS) || (!bNegative && bNegativeS))
	{
		SSS=MultiplyNumericValuesFromStrings(SS,S,Z);
		return Eval(SSS~="0","0",Eval(Left(SSS,1)~="-","","-")$SSS);
	}

	S=FixFloatString(S);
	SS=FixFloatString(SS);
	i=InStr(S,".");
	l=InStr(SS,".");

	if(S~="0" || SS~="0")
	{
		return "0";
	}

	if(i!=-1 || l!=-1)
	{
		if(i!=-1)
		{
			SSS=Left(S,i);
			SSSS=Mid(S,i+1);
			m=iEval((i==-1 || SSSS~="0"),0,Len(SSSS));
			S=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		if(l!=-1)
		{
			SSS=Left(SS,l);
			SSSS=Mid(SS,l+1);
			n=iEval((l==-1 || SSSS~="0"),0,Len(SSSS));
			SS=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		if(S~="0" || SS~="0")
		{
			return "0";
		}

		SSS=GetNumericStringValueFromString(MultiplyNumericValuesFromStrings(S,SS));

		while(Len(SSS)<=m+n)
		{
			SSS="0"$SSS;
		}

		SSS=Left(SSS,Len(SSS)-m-n)$"."$Mid(SSS,Len(SSS)-m-n);

		if(Z>=0)
		{
			SSS=ReduceFloatString(SSS,Z);
		}

		return FixFloatString(SSS);
	}

	if(S~="0" || SS~="0")
	{
		return "0";
	}

	for(i=0;i<Len(SS);i++)
	{
		SSS=S;
		m=GetNumericValueFromString(Mid(SS,Len(SS)-i-1,1));
		n=0;

		if(m==0)
		{
			continue;
		}

		for(k=0;k<Len(SSS);k++)
		{
			l=GetNumericValueFromString(Mid(SSS,Len(SSS)-k-1,1));
			l=l*m+n;
			n=iEval(l<10,0,iLeft(l,iLen(l)-1));
			l=l%10;
			SSS=Left(SSS,Len(SSS)-k-1)$l$Mid(SSS,Len(SSS)-k);
		}

		if(n>0)
		{
			SSS=n$SSS;
		}

		for(k=0;k<i;k++)
		{
			SSS$="0";
		}

		SSSS=AddNumericValuesFromStrings(SSSS,SSS);
	}

	return GetNumericStringValueFromString(SSSS);
}

static function string DivideNumericValuesFromStrings(string S, string SS, optional int Z)
{
	local int i,l,m,n,k,j,p;
	local bool bNegative,bNegativeS;
	local string SSS,SSSS,SSSSS;

	Z=Clamp(Z,0,100);

	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
		bNegative=True;
	}

	if(Left(SS,1)~="-")
	{
		SS=Mid(SS,1);
		bNegativeS=True;
	}

	S=FixFloatString(S);
	SS=FixFloatString(SS);

	if((bNegative && !bNegativeS) || (!bNegative && bNegativeS))
	{
		SSS=DivideNumericValuesFromStrings(S,SS,Z);
		return Eval(SSS~="0","0",Eval(Left(SSS,1)~="-","","-")$SSS);
	}

	i=InStr(S,".");
	l=InStr(SS,".");

	if(i!=-1 || l!=-1)
	{
		if(i!=-1)
		{
			SSS=Left(S,i);
			SSSS=Mid(S,i+1);
			m=iEval((i==-1 || SSSS~="0"),0,Len(SSSS));
			S=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		if(l!=-1)
		{
			SSS=Left(SS,l);
			SSSS=Mid(SS,l+1);
			n=iEval((l==-1 || SSSS~="0"),0,Len(SSSS));
			SS=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));
		}

		while(m<n)
		{
			S$="0";
			m++;
		}

		while(n<m)
		{
			SS$="0";
			n++;
		}

		if(S~="0" || SS~="0")
		{
			return "0";
		}

		S=DivideNumericValuesFromStrings(S,SS,Z);
		i=InStr(SSS,".");
		SSS=Left(S,i);
		SSSS=Mid(S,i+1);
		k=iEval((i==-1 || SSSS~="0"),0,Len(SSSS));
		SSS=GetNumericStringValueFromString(Eval(SSS~="0",SSSS,Eval(SSSS~="0",SSS,SSS$SSSS)));

		while(Len(SSS)<=m+n+k)
		{
			SSS="0"$SSS;
		}

		SSS=Left(SSS,Len(SSS)-n-m-k)$"."$Mid(SSS,Len(SSS)-n-m-k);

		if(Z>=0)
		{
			SSS=ReduceFloatString(SSS,Z);
		}

		return FixFloatString(SSS);
	}

	if(S~="0" || SS~="0" || (GreaterNumericValueOfStrings(S,SS)==2 && Z<=0))
	{
		return "0";
	}

	n=Len(S)+1;
	j=n+1;
	m=0;
	SSSSS=S;

	for(i=0;(i+Len(SS)<=Len(S) || p<Z);i++)
	{
		if(SSSSS~="0")
		{
			break;
		}

		if(i+Len(SS)>=Len(S) && GreaterNumericValueOfStrings(SSSSS,SS)==2)
		{
			if(i==0)
			{
				j=Len(S)+2;
				n=Len(S)+1;
				m=-1;
			}

			if(GetNumericStringValueFromString(SSSS)!="0")
			{
				SSSS$="0";
			}

			SSSSS$="0";
			p++;
		}

		SSS=GetNumericStringValueFromString(Left(SSSSS,Len(SS)+i-m));

		if(GreaterNumericValueOfStrings(SSS,SS)==2)
		{
			continue;
		}

		for(l=1;GreaterNumericValueOfStrings(SSS,MultiplyNumericValuesFromStrings(SS,string(l+1)))<=1;l++);

		SSS=string(l);

		for(k=0;(k<Len(S)-i-Len(SS) && p<=0);k++)
		{
			SSS$="0";
		}

		j=n;
		n=Len(SSSSS);
		SSSSS=SubtractNumericValuesFromStrings(SSSSS,MultiplyNumericValuesFromStrings(SS,SSS));
		SSSS=AddNumericValuesFromStrings(SSSS,SSS);
		m+=(j-Len(SSSSS))-(j-n);
	}

	while(Len(SSSS)<=Z)
	{
		SSSS="0"$SSSS;
	}

	SSSS=Left(SSSS,Len(SSSS)-p)$"."$Mid(SSSS,Len(SSSS)-p);

	if(Z>=0)
	{
		SSSS=ReduceFloatString(SSSS,Z);
	}

	return FixFloatString(SSSS);
}

static function string LimitNumericValueFromStrings(string S, string SS, optional int Z)
{
	if(S~="0" || SS~="0")
	{
		return "0";
	}
	else if(GreaterNumericValueOfStrings(S,SS)==2)
	{
		return S;
	}

	return SubtractNumericValuesFromStrings(S,MultiplyNumericValuesFromStrings(SS,DivideNumericValuesFromStrings(S,SS)),Z);
}

static function string AbsNumericValueFromString(string S)
{
	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
	}

	return FixFloatString(S);
}

static function string MinNumericValueFromStrings(string S, string SS)
{
	S=FixFloatString(S);
	SS=FixFloatString(SS);

	if(GreaterNumericValueOfStrings(S,SS)==1)
	{
		return SS;
	}

	return S;
}

static function string MaxNumericValueFromStrings(string S, string SS)
{
	S=FixFloatString(S);
	SS=FixFloatString(SS);

	if(GreaterNumericValueOfStrings(S,SS)==2)
	{
		return SS;
	}

	return S;
}

static function string ClampNumericValueFromStrings(string S, string SS, string SSS)
{
	S=FixFloatString(S);
	SS=FixFloatString(SS);
	SSS=FixFloatString(SSS);

	return MinNumericValueFromStrings(SSS,MaxNumericValueFromStrings(S,SS));
}

static function string RandNumericValueFromStrings(string S, optional string SS)
{
	local string SSS,SSSS,SSSSS;
	local int i;

	if(SS=="")
	{
		SS=S;
		S="0";
	}

	S=MaxNumericValueFromStrings(ConvertFloatStringToIntString(S),"0");
	SS=MaxNumericValueFromStrings(ConvertFloatStringToIntString(SS),"0");

	if(GreaterNumericValueOfStrings(S,SS)<=1)
	{
		return S;
	}

	SSSSS=SubtractNumericValuesFromStrings(SS,S);

	for(i=0;i<Len(SSSSS);i++)
	{
		if(i==Len(SSSSS)-1)
		{
			SSSS=SSS;

			while(Len(SSSS)>1 && Left(SSSS,1)~="0")
			{
				SSSS=Mid(SSSS,1);
			}

			SSSS=SubtractNumericValuesFromStrings(SSSSS,SSSS);

			if(Len(SSSS)<Len(SSSSS))
			{
				SSSS="0";
			}
			else
			{
				SSSS=string(Rand(GetNumericValueFromString(Left(SubtractNumericValuesFromStrings(SSSSS,SSS),1))+1));
			}
		}
		else
		{
			SSSS=string(Rand(10));
		}

		SSS=Eval(SSS=="",SSSS,SSSS$SSS);
	}

	while(Len(SSS)>1 && Left(SSS,1)~="0")
	{
		SSS=Mid(SSS,1);
	}

	SSS=GetNumericStringValueFromString(SSS);

	return AddNumericValuesFromStrings(S,SSS);
}

static function string LerpNumericValueFromString(string S, string SS, string SSS, optional int Z)
{
	S=FixFloatString(S);
	SS=FixFloatString(SS);
	SSS=FixFloatString(SSS);

	return AddNumericValuesFromStrings(S,MultiplyNumericValuesFromStrings(SSS,SubtractNumericValuesFromStrings(SS,S)),Z);
}

static function string FixBinaryString(string S)
{
	local int i;
	local string SS;

	SS="0";

	for(i=0;i<Len(S);i++)
	{
		if(Mid(S,i,1)~="0")
		{
			SS=Eval(SS~="0","0",SS$"0");
		}
		else if(Mid(S,i,1)~="1")
		{
			SS=Eval(SS~="0","1",SS$"1");
		}
	}

	return SS;
}

static function string BinaryNumericValueFromString(string S)
{
	local string SS,i,l,m,n,j;

	S=ConvertFloatStringToIntString(S);

	while(S!="")
	{
		m=S;
		l=m;

		if(m~="0")
		{
			return "0";
		}

		if(GreaterNumericValueOfStrings(l,"0")==1)
		{
			l="1";

			while(GreaterNumericValueOfStrings(m,l)<=1)
			{
				n=l;
				l=MultiplyNumericValuesFromStrings(l,"2");
			}

			i=n;

			while(GreaterNumericValueOfStrings(j,MultiplyNumericValuesFromStrings(i,"2"))==1)
			{
				SS$="0";
				i=MultiplyNumericValuesFromStrings(i,"2");
			}

			j=n;
			i="1";
			SS$="1";
			m=SubtractNumericValuesFromStrings(m,n);
			n="1";

			if(m~="0")
			{
				n="1";

				while(GreaterNumericValueOfStrings(MultiplyNumericValuesFromStrings(n,"2"),l)==2)
				{
					SS$="0";
					n=MultiplyNumericValuesFromStrings(n,"2");
				}

				S="";
			}
			else
			{
				S=m;
			}
		}
	}

	l="1";

	while(GreaterNumericValueOfStrings(i,l)==1)
	{
		SS$="0";
		l=AddNumericValuesFromStrings(l,"1");
	}

	return FixBinaryString(SS);
}

static function string NumericValueFromBinaryString(string S)
{
	local int i,n;
	local string l,m;

	S=FixBinaryString(S);

	while(S!="")
	{
		l=Left(S,1);
		n=Len(S);
		S=Mid(S,1);

		if(l=="1")
		{
			i=1;

			while(i<n)
			{
				l=MultiplyNumericValuesFromStrings(l,"2");
				i++;
			}

			m=AddNumericValuesFromStrings(m,l);
		}
	}

	return GetNumericStringValueFromString(m);
}

static function string BitwiseAndNumericValueFromString(string S, string SS)
{
	local int i,l;
	local string SSS,SSSS;

	S=BinaryNumericValueFromString(S);
	SS=BinaryNumericValueFromString(SS);
	l=-1;

	while(i<Len(S) && i<Len(SS))
	{
		SSSS=Mid(S,Len(S)-i-1,1);

		if(SSSS~="1" && SSSS~=Mid(SS,Len(SS)-i-1,1))
		{
			l++;

			while(l<i)
			{
				SSS="0"$SSS;
				l++;
			}

			SSS="1"$SSS;
		}

		i++;
	}

	return NumericValueFromBinaryString(SSS);
}

static function string BitwiseOrNumericValueFromString(string S, string SS)
{
	local int i,l;
	local string SSS;

	S=BinaryNumericValueFromString(S);
	SS=BinaryNumericValueFromString(SS);
	l=-1;

	while(i<Len(S) || i<Len(SS))
	{
		if(Mid(S,Len(S)-i-1,1)~="1" || Mid(SS,Len(SS)-i-1,1)~="1")
		{
			l++;

			while(l<i)
			{
				SSS="0"$SSS;
				l++;
			}

			SSS="1"$SSS;
		}

		i++;
	}

	return NumericValueFromBinaryString(SSS);
}

static function string BitwiseXORNumericValueFromString(string S, string SS)
{
	local int i,l;
	local string SSS;

	S=BinaryNumericValueFromString(S);
	SS=BinaryNumericValueFromString(SS);
	l=-1;

	while(i<Len(S) || i<Len(SS))
	{
		if((Mid(S,Len(S)-i-1,1)~="1" || Mid(SS,Len(SS)-i-1,1)~="1") && Mid(S,Len(S)-i-1,1)!=Mid(SS,Len(SS)-i-1,1))
		{
			l++;

			while(l<i)
			{
				SSS="0"$SSS;
				l++;
			}

			SSS="1"$SSS;
		}

		i++;
	}

	return NumericValueFromBinaryString(SSS);
}

static function string ReduceFloatString(string S, int i)
{
	local int l,m,n;
	local string SS,SSS;

	S=FixFloatString(S);

	if(i<=0)
	{
		return ConvertFloatStringToIntString(S);
	}

	l=InStr(S,".");

	if(l!=-1)
	{
		SS=Left(S,l);
		SSS=Mid(S,l+1,i);
		m=0;

		while(Left(SSS,1)~="0")
		{
			SSS=Mid(SSS,1);
			m++;
		}

		SSS=GetNumericStringValueFromString(SSS);

		if(!(SSS~="0"))
		{
			for(n=0;n<m;n++)
			{
				SSS="0"$SSS;
			}
		}

		S=Eval(SSS~="0",SS,SS$"."$SSS);
	}

	return FixFloatString(S);
}

static function string FixFloatString(string S)
{
	local int i,l;
	local string SS,SSS;

	i=InStr(S,".");
	l=InStr(S,",");
	i=iEval(i==-1,l,iEval(l==-1,i,Min(i,l)));

	if(i!=-1)
	{
		SS=GetNumericStringValueFromString(Left(S,i));
		SSS=Mid(S,i+1);

		if(!(SSS~="0"))
		{
			l=0;

			while(Left(SSS,1)~="0")
			{
				SSS=Mid(SSS,1);
				l++;
			}

			SSS=ConvertFloatStringToIntString(SSS);

			if(!(SSS~="0"))
			{
				while(Right(SSS,1)~="0")
				{
					SSS=Left(SSS,Len(SSS)-1);
				}

				SSS=GetNumericStringValueFromString(SSS);

				for(i=0;i<l;i++)
				{
					SSS="0"$SSS;
				}
			}
		}

		S=Eval(SSS~="0",SS,SS$"."$SSS);
	}
	else
	{
		S=GetNumericStringValueFromString(S);
	}

	return S;
}

static function string ConvertFloatStringToIntString(string S)
{
	local int i,l;

	i=InStr(S,".");
	l=InStr(S,",");
	i=iEval(i==-1,l,iEval(l==-1,i,Min(i,l)));

	if(i!=-1)
	{
		S=Left(S,i);
	}

	return GetNumericStringValueFromString(S);
}

static function string GetNumericStringValueFromString(string S)
{
	local string SS;
	local int i,l;

	if(Left(S,1)~="-")
	{
		SS=Left(S,1);
		S=Mid(S,1);
	}

	if(S=="")
	{
		return "0";
	}

	for(i=0;i<Len(S);i++)
	{
		l=GetNumericValueFromString(Mid(S,i,1));

		if(l==0 && (!(Mid(S,i,1)~="0") || SS~="-" || SS~=""))
		{
			SS="0";
			break;
		}

		SS$=string(l);
	}

	return SS;
}

static function int GetNumericValueFromString(string S)
{
	local int i,l,m;
	local bool bNegative;

	if(Left(S,1)~="-")
	{
		S=Mid(S,1);
		bNegative=True;
	}

	for(i=0;i<Len(S);i++)
	{
		for(l=0;l<10;l++)
		{
			if(Mid(S,i,1)~=string(l))
			{
				if(l==0 && m==0)
				{
					l=10;
					break;
				}
				else
				{
					m+=l*(10**(Len(S)-i-1));
				}

				break;
			}
		}

		if(l>=10)
		{
			m=0;
			break;
		}
	}

	if(bNegative)
	{
		m*=-1;
	}

	return m;
}

static function Exchange(out string A, out string B)
{
	local string C;

	C=A;
	A=B;
	B=C;
}
/*
static function bExchange(out bool A, out bool B)
{
	local bool C;

	C=A;
	A=B;
	B=C;
}
*/
static function iExchange(out int A, out int B)
{
	local int C;

	C=A;
	A=B;
	B=C;
}

static function fExchange(out float A, out float B)
{
	local float C;

	C=A;
	A=B;
	B=C;
}

static function vExchange(out vector A, out vector B)
{
	local vector C;

	C=A;
	A=B;
	B=C;
}

static function rExchange(out rotator A, out rotator B)
{
	local rotator C;

	C=A;
	A=B;
	B=C;
}

static function cExchange(out color A, out color B)
{
	local color C;

	C=A;
	A=B;
	B=C;
}

static function int iLen(int A)
{
	local float B;
	local int C;

	B = A;

	while(B >= 1)
	{
		B *= 0.1;
		C++;
	}

	return C;
}

static function int iMid(int A, int i, optional int j)
{
	A = iRight(A,iLen(A) - i);

	if(j > 0)
	{
		A = iLeft(A,j);
	}

	return A;
}

static function int iLeft(int A, int i)
{
	local float B;

	if(i <= 0)
	{
		return 0;
	}
	else if(i >= iLen(A))
	{
		return A;
	}

	B = A;

	while(iLen(int(B)) > i)
	{
		B *= 0.1;
	}

	return int(B);
}

static function int iRight(int A, int i)
{
	local int B;

	if(i <= 0)
	{
		return 0;
	}
	else if(i >= iLen(A))
	{
		return A;
	}

	B = iLeft(A,iLen(A) - i);

	while(iLen(B) < iLen(A))
	{
		B *= 10;
	}

	return A - B;
}

static function bool bEval(bool A, bool B, bool C)
{
	if(A)
	{
		return B;
	}

	return C;
}

static function int iEval(bool A, int B, int C)
{
	if(A)
	{
		return B;
	}

	return C;
}

static function float fEval(bool A, float B, float C)
{
	if(A)
	{
		return B;
	}

	return C;
}

static function vector vEval(bool A, vector B, vector C)
{
	if(A)
	{
		return B;
	}

	return C;
}

static function rotator rEval(bool A, rotator B, rotator C)
{
	if(A)
	{
		return B;
	}

	return C;
}

static function color cEval(bool A, color B, color C)
{
	if(A)
	{
		return B;
	}

	return C;
}

defaultproperties
{
}
