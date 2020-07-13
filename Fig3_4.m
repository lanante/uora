
clear
clc
close all

N_STA_Array=[4:16];                 %N_STA
tACK=68e-6;                         %ACK duration
tTO=16e-6;                          %Time out duration when no transmission occured
tpreamblePHY=40e-6;                 %PHY preamble duration
tTXOP=3.844e-3;                     %TXOP duration
tSIFS=16e-6;                        %SIFS duration
tTF=100e-6;                         %Trigger Frame Duraton
PHY=.8*1e6;                         %PHY Data Rate of 1 RU
EP=PHY*(tTXOP-tpreamblePHY);        %Packet Payload
Param.tTXOP=tTXOP;
Param.tTF=tTF;
Param.tSIFS=tSIFS;  


R=4;                                %Baseline N_RU
Ts=tTF+3*tSIFS+tTXOP+tACK;
Twait=tTF+tTO;
%% Parameter Optimization 
%Full Search 
for j=1:length(N_STA_Array)
    N_STA=N_STA_Array(j);
    if N_STA<R
        N_RU=N_STA;
    else
        N_RU=R;
    end
    for i=0:7   %%%EOCWmin
        W=2^i;
        for ii=i:7   %%%EOCWmax
            CWOmin=2.^i-1;
            CWOmax=2.^ii-1;
            [ Efficiency_ana(i+1,ii+1),tau]=analysis_random_access(N_STA,N_RU,CWOmin,CWOmax);
            Pwait=(1-tau)^N_STA;  %Probability of no Transmission
            Throughput_ana(i+1,ii+1)=Efficiency_ana(i+1,ii+1)* N_RU*EP*8/(Twait*Pwait+Ts*(1-Pwait));
        end
    end
    
    a=max(Throughput_ana);
    b=max(a);
    ind2=find(max(Throughput_ana)==b);
    ind1=find(Throughput_ana(:,ind2)==b);
    EOCWmax_FS(j)=ind2(1)-1;
    EOCWmin_FS(j)=ind1(1)-1;
end



%Low Complexity Search
    EOCWmin_LC=0;
    W=2^EOCWmin_LC;   %%%EOCWmin
for j=1:length(N_STA_Array)
    N_STA=N_STA_Array(j);
    if N_STA<R
        N_RU=N_STA;
    else
        N_RU=R;
    end
    for ii=i:7   %%%EOCWmax
        CWOmin=2.^i-1;
        CWOmax=2.^ii-1;
        [ Efficiency_ana(1,ii+1),~]=analysis_random_access(N_STA,N_RU,CWOmin,CWOmax);
    end
    a=max(Efficiency_ana);
    b=max(a);
    ind2=find(max(Efficiency_ana)==b);
    ind1=find(Efficiency_ana(:,ind2)==b);
    EOCWmax_LC(j)=ind2(1)-1;
    
end


%% Simulations 

%Simulation Variables
simTime=2 ;        %Simulated Duration per Iteration
Iteration=10;    


%Optimized Algorithm Simulations
for j=1:length(N_STA_Array)
   N_STA=N_STA_Array(j);
    if N_STA<R
        N_RU=N_STA;
    else
        N_RU=R;
    end
    CWOmin_FS=2.^EOCWmin_FS(j)-1;
    CWOmax_FS=2.^EOCWmax_FS(j)-1;
    CWOmin_LC=2.^EOCWmin_LC-1;   
    CWOmax_LC=2.^EOCWmax_LC(j)-1;
    for ite=1:Iteration
        [ EfficiencyA_FS(ite),meanRetryA_FS(ite),Packets_per_secA_FS(ite)]=sim_random_access(N_STA,N_RU,CWOmin_FS,simTime,CWOmax_FS,Param);
        [ EfficiencyA_LC(ite),meanRetryA_LC(ite),Packets_per_secA_LC(ite)]=sim_random_access(N_STA,N_RU,CWOmin_LC,simTime,CWOmax_LC,Param);
    end
    Efficiency_sim_FS(j)=mean(EfficiencyA_FS);
    Efficiency_sim_LC(j)=mean(EfficiencyA_LC);
    
    meanRetry_sim_FS(j)=mean(meanRetryA_FS);
    meanRetry_sim_LC(j)=mean(meanRetryA_LC);
    
    Tput_sim_FS(j)=mean(Packets_per_secA_FS)*EP;
    Tput_sim_LC(j)=mean(Packets_per_secA_LC)*EP;
end

%No-Optimization Simulation (Random)
for j=1:length(N_STA_Array)
    tic
    c=0;
    N_STA=N_STA_Array(j);
    for i=0:7
        for ii=0:7
            CWOmin=2.^(i)-1;
            CWOmax=2.^(ii)-1;
            for ite=1:Iteration
                [ EfficiencyA(ite),meanRetryA(ite),Packets_per_secA(ite)]=sim_random_access(N_STA,R,CWOmin,simTime,CWOmax,Param);
            end
            c=c+1;
            Efficiency_sim(j,c)=mean(EfficiencyA);
            meanRetry_sim(j,c)=mean(meanRetryA);
            Tput_sim(j,c)=mean(Packets_per_secA)*EP;
        end
    end
    toc
end


%% Plot Results
set(0,'DefaultAxesFontName', 'Helvetica')

figure(1); hold on;
plot(N_STA_Array,Tput_sim_FS/1e6,'k-o','LineWidth',2)
plot(N_STA_Array,Tput_sim_LC/1e6,'k:s','LineWidth',2)
for i=1:size(Tput_sim,2)
    plot(N_STA_Array,Tput_sim(:,i)/1e6,'k*')
    
end
axis([4 16 0.0 4])
xlabel('Number of Stations');
ylabel('Throughput [Mbps]');
grid
legend('Full search Method','Low Complexity Method','Random')


figure(2); hold on;
set(0,'DefaultAxesFontName', 'Helvetica')
plot(N_STA_Array,meanRetry_sim_FS,'k-o')
plot(N_STA_Array,meanRetry_sim_LC,'k:^')
plot(N_STA_Array,mean(meanRetry_sim,2),'k-*')
axis([4 16 0.0 16])
xlabel('Number of Stations');
ylabel('Number of Retries');
grid
legend('Full search Method','Low Complexity Method','Random (Average)')











