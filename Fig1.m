clc
clear
close all

% Parameters
N_RUarray=[1 4 8 16];               %Array of Number of RUs
EOCWmax=7;                          %MAX OFDMA Contention Window exponent
EOCWminArray=0:7;                   %MIN OFDMA Contention Window exponent array
N_STA=4;                            %N_STA

tTXOP=3.844e-3;                     %TXOP duration
tSIFS=16e-6;                        %SIFS duration
tTF=100e-6;                         %Trigger Frame Duraton

Param.tTXOP=tTXOP;
Param.tTF=tTF;
Param.tSIFS=tSIFS;  

%Simulation Variables
simTime=2 ;                         %Simulated Duration per Iteration
Iteration=10;    
Efficiency_ana=zeros(length(N_RUarray),length(EOCWminArray));
EfficiencyA=zeros(1,Iteration);
Efficiency_sim=zeros(length(N_RUarray),length(EOCWminArray));
               
for i=1:length(EOCWminArray)
    tic
    EOCWmin=EOCWminArray(i);
    CWOmin=2.^EOCWmin-1;
    CWOmax=2.^EOCWmax-1;
    for j=1:length(N_RUarray)
        N_RU=N_RUarray(j);
        [ Efficiency_ana(j,i)]=analysis_random_access(N_STA,N_RU,CWOmin,CWOmax);
        for ite=1:Iteration
            [ EfficiencyA(ite)]=sim_random_access(N_STA,N_RU,CWOmin,simTime,CWOmax,Param);
        end
        Efficiency_sim(j,i)=mean(EfficiencyA);
    end
    toc
end

set(0,'DefaultAxesFontName', 'Times New Roman','DefaultAxesFontsize',12,'DefaultTextFontsize',12)
plot(EOCWminArray,Efficiency_ana(1,:),'k-',EOCWminArray,Efficiency_ana(2,:),'k:',EOCWminArray,Efficiency_ana(3,:),'k-.',EOCWminArray,Efficiency_ana(4,:),'k--','LineWidth',2)
 hold on;
plot(EOCWminArray,Efficiency_sim(1,:),'ko',EOCWminArray,Efficiency_sim(2,:),'k^',EOCWminArray,Efficiency_sim(3,:),'ks',EOCWminArray,Efficiency_sim(4,:),'kp','LineWidth',1)
legend('Analytical r=1','Analytical r=4','Analytical r=8','Analytical r=16','Simulation r=1','Simulation r=4','Simulation r=8','Simulation r=16');
axis([0 7 0.0 1.0])
xlabel('EOCW_{min}');
ylabel('Efficiency');
grid

