clc
clear
close all

% Parameters
N_RUarray=[4 8 16 32];               %Array of Number of RUs
EOCWmax=7;                          %MAX OFDMA Contention Window exponent
EOCWmin=0;                          %MIN OFDMA Contention Window exponent
N_STA_Array=1:4:64;                 %N_STA Array

tTXOP=3.844e-3;                     %TXOP duration
tSIFS=16e-6;                        %SIFS duration
tTF=100e-6;                         %Trigger Frame Duraton

Param.tTXOP=tTXOP;
Param.tTF=tTF;
Param.tSIFS=tSIFS;  

%Simulation Variables
simTime=2 ;                         %Simulated Duration per Iteration
Iteration=10;
Efficiency_ana=zeros(length(N_RUarray),length(N_STA_Array));
EfficiencyA=zeros(1,Iteration);
Efficiency_sim=zeros(length(N_RUarray),length(N_STA_Array));

for j=1:length(N_RUarray)
    tic
    N_RU=N_RUarray(j);
    for i=1:length(N_STA_Array)
        N_STA=N_STA_Array(i);
        CWOmin=2.^EOCWmin-1;
        CWOmax=2.^EOCWmax-1;
        [ Efficiency_ana(j,i)]=analysis_random_access(N_STA,N_RU,CWOmin,CWOmax);
        for ite=1:Iteration
            [ EfficiencyA(ite)]=sim_random_access(N_STA,N_RU,CWOmin,simTime,CWOmax,Param);
        end
        Efficiency_sim(j,i)=mean(EfficiencyA);
    end
toc   
end

set(0,'DefaultAxesFontName', 'Times New Roman','DefaultAxesFontsize',12,'DefaultTextFontsize',12)
plot(N_STA_Array,Efficiency_ana(1,:),'k-',N_STA_Array,Efficiency_ana(2,:),'k:',N_STA_Array,Efficiency_ana(3,:),'k-.',N_STA_Array,Efficiency_ana(4,:),'k--','LineWidth',2)
hold on;
plot(N_STA_Array,Efficiency_sim(1,:),'ko',N_STA_Array,Efficiency_sim(2,:),'k^',N_STA_Array,Efficiency_sim(3,:),'ks',N_STA_Array,Efficiency_sim(4,:),'kp','LineWidth',1)
legend('Analytical r=4','Analytical r=8','Analytical r=16','Analytical r=32','Simulation r=4','Simulation r=8','Simulation r=16','Simulation r=32');
axis([1 61 0.0 1.0])
xlabel('Number of STAs');
ylabel('Efficiency');
grid










