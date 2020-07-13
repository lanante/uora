function [Efficiency,  meanRetry, Packets_per_sec]=sim_random_access(N_STA,N_RU,CWOmin,SimTime,CWOmax,Param)
RETRYmax=10000;
A_CWO=ones(1,N_STA)*CWOmin;   %Contention windows
A_BO=fresh_BO(A_CWO);		  %Backoff counters
A_Retry=zeros(1,N_STA);		  %Retry Counters


tTXOP=Param.tTXOP;
tTF=Param.tTF;
tSIFS=Param.tSIFS;

%Simulation Variables
tim=1e-10+tTF+tSIFS;
NRU_cnt=0;
S_cnt=0;
colls=zeros(N_STA,RETRYmax);
succs=zeros(N_STA,RETRYmax);
s_cnt=zeros(1,N_STA);

for i=1:1e10
    
    %Define Active Users
    Send_set=1:N_STA; %STAs that are waiting to send, Currently Full Buffer case. When non full buffer, Send_set should be a subset of 1:N_STA
    RU_occupied=zeros(N_STA,N_RU);
    
    %Search Users with zero BO
    a=find(A_BO(Send_set)-N_RU<=0); %STA numbers of STAs that will transmit after this TF
    b=find(A_BO(Send_set)-N_RU>0); %STA numbers of STAs that will not transmit after this TF
    
    if ~isempty(a)
        tim=tim+tTXOP+tSIFS+tTF+tSIFS;
    else
        tim=tim+tTF+tSIFS;
    end
    
    for sta=1:N_STA
        Retries(i,sta)=A_Retry(sta); %#ok<AGROW>
    end
    
    %Transmitting STAs, update BO, Check for Collision
    for c=1:length(a)  %row is station, column is RU that it will send
        RU_occupied(Send_set(a(c)),randi(N_RU))=1; %there is collision if there are two or more entries in one column
    end
    s_cnt(Send_set)=0;   
    for n_ru=1:N_RU %test for collision
        d=find(RU_occupied(:,n_ru)==1); %stas that will send in n_ru RU
        if ~isempty(d)
            %find users with zero BO
            if length(d)==1  %successful
                succs(d,A_Retry(d)+1)=succs(d,A_Retry(d)+1)+1;
                s_cnt(d)=s_cnt(d)+1;
                A_Retry(d)=0;  %reset retry counter to zero
                A_CWO(d)=inc_OCW(A_Retry(d),CWOmin,CWOmax);  %reset CWO
                A_BO(d)=fresh_BO(A_CWO(d));
            elseif length(d)>1    %collision
                for sta=1:length(d)
                    colls(d(sta),A_Retry(d(sta))+1)=colls(d(sta),A_Retry(d(sta))+1)+1;
                    A_Retry(d(sta))=A_Retry(d(sta))+1;
                    if A_Retry(d(sta))==RETRYmax
                        A_CWO(d(sta))=inc_OCW(0,CWOmin,CWOmax);  %reset CWO
                        A_BO(d(sta))=fresh_BO(A_CWO(d(sta)));
                    else
                        A_CWO(d(sta))=inc_OCW(A_Retry(d(sta)),CWOmin,CWOmax);  %reset CWO
                        A_BO(d(sta))=fresh_BO(A_CWO(d(sta)));
                    end
                end
            end
        end
    end
    
    %Non transmitting STAs, update BO
    A_BO(Send_set(b))=A_BO(Send_set(b))-N_RU;
    
    
    
    S_cnt=S_cnt+s_cnt;
    NRU_cnt= NRU_cnt+N_RU;
    if tim>=SimTime
        break;
    end
end
Efficiency=sum(S_cnt)/NRU_cnt;
Packets_per_sec=sum(S_cnt)/tim;
meanRetry=mean(mean(Retries));
end



function new_BO = fresh_BO(OCW)
for n_sta=1:length(OCW)
    new_BO=randi(OCW(n_sta)+1,1,length(OCW))-1;
end
end

function new_OCW=inc_OCW(Retry,OCWmin,OCWmax)
new_OCW=(OCWmin+1)*2.^(Retry)-1;
new_OCW(new_OCW>OCWmax)=OCWmax;
end
