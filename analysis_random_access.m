function [EfficiencyT, tau]=analysis_random_access(n,r,CWOmin,CWOmax)

sp=0;
res=1e4;
tau=linspace(1/res,1-1/res,res);
W=CWOmin+1;
m=log2(CWOmax+1)- log2(CWOmin+1);
p=1-(1-tau/r).^(n-1);
for ii=0:(m-1)
    sp=sp+(2*p).^ii;
end
c=floor(log2(r));

if mod(log2(r),1)==0  %%%currently support r is a power of 2
    A=W*(1-p-p.*(2*p).^m)./(1-2*p)+(r-2)+((2*r)./W).*(1-p+p/2.*(p/2).^m)./(1-p/2);
    B=(r+2)*(1-p.^(c+1)) -  W*(1-p-(2*p).^(c+1)+p.*(2*p).^(c+1))./(1-2*p) - 2*r/W*(1-p-(p/2).^(c+1)+p.*(p/2).^(c+1))./(1-p/2) +A ;
    Q=(W^2+(r-2)*W+2*r)./(2*r*W);
else
    error('Currently unsupported N_{RU}');
end


if m==0
    tau1=1/Q*ones(1,length(p));
else
    if r>=W*2^m
        tau1=ones(1,length(p));
    elseif r<= W
        tau1=2*r./(A);
    else
        tau1=2*r./(B);
    end
end
p2=1-((1-tau1/r).^(n-1));


[~,b,]=min(abs(p-p2));
tau=tau1(b);  %probability of transmitting when non idle
pTr=1-(1-tau/r)^(n);   % probability that a transmission is made  per RU
pS=n*tau/r*(1-tau/r)^(n-1)/pTr; %probability of success when a transmission is made per RU
EfficiencyT=pS*pTr;
