function [parms, goodness] = gambfit(subjectNo,condition)
% condition 1=rew, 2=pun, 3=neut

global subject;
if length(subjectNo)==1
    subject=subjectNo;
end

choice=[];
outcome=[];
rewTime=[];
cueTime=[];
result=[];
%subjectNo=[2 4 5 6 7];

for(k=1:length(subjectNo)) %reading in the data and making data vectors if group-fitting
    for session=1:2
        startTime=['C:\Users\larsent\Documents\MATLAB\opponentAnalysis\startTime' num2str(subjectNo(k)) '_' num2str(session) '.mat'];
        [choiceNew outcomeNew timeNew]=opponentDataFunc(subjectNo(k),session);
        resultNew=outcomeNew;
%         if(~isempty(outcomeNew))
%             resultNew(61:90)=outcomeNew(61:90).*1;
%         else
%             resultNew=[];
%         end
     %   k
    switch condition
        case 1
            choiceNew=choiceNew(1:30);
            outcomeNew=outcomeNew(1:30);
            timeNew=timeNew(1:30,:);
    %     resultNew=resultNew(1:30);
        case 2
            choiceNew=choiceNew(31:60);
            outcomeNew=outcomeNew(31:60);
            timeNew=timeNew(31:60,:);
%         resultNew=resultNew(31:60);
        case 3
            choiceNew=choiceNew(61:90);
            outcomeNew=outcomeNew(61:90);
            timeNew=timeNew(61:90,:);
        case 4
            choiceNew=choiceNew(1:60);
            outcomeNew=outcomeNew(1:60);
            timeNew=timeNew(1:60,:);
        case 5
            choiceNew=choiceNew(1:90);
            outcomeNew=outcomeNew(1:90);
            timeNew=timeNew(1:90,:);            
    end
    %     resultNew=resultNew(1:60);
    %     cueTimeNew=cueTimeNew(1:90);
        choice=[choice; choiceNew];
        outcome=[outcome; outcomeNew];
%         result=[result; resultNew];
        cueTime=[cueTime; timeNew(:,1)];
        rewTime=[rewTime; timeNew(:,3)];
        clear choiceNew timeNew outcomeNew;
    end
end

condition=round(length(choice)/30)-1; % # of conditions-1
x0(1)=rand; x0(2)=rand; x0(3)=rand;% x0(4)=rand*5; x0(5) = rand*5; x0(6)=rand*5; x0(7)=rand-0.5; %starting parameters
% x0(1)=0.830828627896291;x0(2)=0.585264091152707;x0(3)=0.549723608291140;
% x0(1)=1.0000; x0(2)=0.9564;
% x0(1)=0.9964;x0(2)=0.0773;x0(3)=0.01707;
%%%Function call to hill-climbing (search) algorithm
[parms goodness exitFlag] = fminsearchbnd(@(x0) rlfitter(x0,outcome,choice,result,rewTime,cueTime,condition,0), x0,[0.05 0.01 -1],[1 10 1]); %, options);
% x0=[8.21798185057787e-12,4.17884070333616];
%%% for creating model output files with fixed (found) parameters
% x0(1)=0.2775;x0(2)=0.6309;x0(3)=0.9681; %HC rew group - no hier
% x0(1)=0.5837;x0(2)=0.4595;x0(3)=0.2849; %HC pun group - no hier
% x0(1)=0.2832;x0(2)=2.7991;x0(3)=0.4084; %HC neu group - hier
% x0(1)=0.1865;x0(2)=0.2574;x0(3)=1.0000; %PPG rew group - no hier
% x0(1)=0.5867;x0(2)=1.0551;x0(3)=1.0000; %PPG pun group - no hier
% x0(1)=0.1857;x0(2)=5.0416;x0(3)=0.4374; %PPG neu group - hier


				


% x0(1) = 0.13; x0(2) = 7.85; %punish params
% x0(1) = 0.02; x0(2) = 26.45; %reward params
% x0(1) = 0.0; x0(2) = 1.2435; %neutral params
% x0(1) = 0.0729; x0(2) = 10.2805; %rew and pun combined params
   
% x0=parms;
% rlfitter(x0,outcome,choice,result,rewTime,cueTime,condition,1);
% parms=choice;
% goodness=outcome;
%parms=[0.5 0.5 0.5 5 5 5];

% goodness=zeros(51,101);
%  for i=0:0.01:0.5
%      for j=0:1:100
%          parms=[i,j];
%          goodness(round(i*100+1),round(j/1+1))=rlfitter(parms,outcome,choice,result,rewTime,cueTime,condition,0); 
%      end
%  end

%[xx,yy]=find(goodness==min(min(goodness)))
% rlfitter([0.0644, 27.3], outcome, choice,result,rewTime,cueTime,condition,0); % just an extra run with the optimal parameters to plot the fit (the '1' is the plot-flag)
%[parms goodness exitFlag] = fminsearch(@(x0) randfit(x0, ...
 %   outcome,choice,condition,0), x0)

%randfit(parms, ...
%   outcome,choice,condition,1) % just an extra run with the optimal parameters to plot the fit (the '1' is the plot-flag)

            
%Model with built-in fitness function
function error = rlfitter(parms, outcome, choice, result, rewTime, cueTime, condition, plot_flag)
global subject;
nTrialsPerCond=30; 
%alpha = [parms(1) parms(1) parms(1)]; %learning rate
alpha = parms(1);
%theta = [parms(2) parms(2) parms(2)]; %softmax temperature
theta = parms(2);
gamma=1;%parms(3);
neut_val=0;
%neut_val=parms(7);

%result(91:135)=outcome(91:135).*neut_val;
result=outcome;
P=[];
Pwl=[];
PwlList=[];

Elist=[];
TDerr=[];
for condI=0:max(condition)
%         E=zeros(1,2);
        E=parms(3).*ones(1,2);
    Elist=[Elist; E];
%     E=0.5*ones(1,2);
    for trialI=1:nTrialsPerCond

        E_neg=E(2:-1:1);
        if(min(E)<0)
            P = [P; (.0001+exp(abs(E_neg/theta)))/((sum(exp(abs(E_neg)/theta)))+.0001)]; 
        else
            P = [P; (.0001+exp(E/theta))/((sum(exp(abs(E)/theta)))+.0001)];
        end
    
        if (trialI>1) %calculate win-stay / lose-shift
            if(choice((condI*nTrialsPerCond+trialI-1))>=0)
                Pwl(trialI,(choice(condI*nTrialsPerCond+trialI-1)+1))=((result(condI*nTrialsPerCond+trialI-1))); %%1+ and abs only needed for aversive learning
%                 Pwl(trialI,(choice(condI*nTrialsPerCond+trialI-1)+1))=1+((result(condI*nTrialsPerCond+trialI-1))); %%1+ and abs only needed for aversive learning
                Pwl(trialI,(3-(choice(condI*nTrialsPerCond+trialI-1)+1)))=1-(((result(condI*nTrialsPerCond+trialI-1)))); % for reward learning
%                 Pwl(trialI,(3-(choice(condI*nTrialsPerCond+trialI-1)+1)))=abs(((result(condI*nTrialsPerCond+trialI-1)))); % for aversive learning
            else
            Pwl(trialI,:)=Pwl(trialI-1,:);
            end
        else
            Pwl=0.5*ones(1,2);
        end

        
        
        if(plot_flag)
            P;
        end

        %Model: Rescorla Wagner learning
        if(choice((condI*nTrialsPerCond+trialI))>=0)
            TDerr=[TDerr; (result(condI*nTrialsPerCond+trialI)-E(choice((condI*nTrialsPerCond+trialI))+1))];
            E(choice((condI*nTrialsPerCond+trialI))+1) = ...
            (1-alpha)*E(choice((condI*nTrialsPerCond+trialI))+1) ...
            + alpha*result(condI*nTrialsPerCond+trialI);
%             E(3-(choice((condI*nTrialsPerCond+trialI))+1)) = E(3-(choice((condI*nTrialsPerCond+trialI))+1)) + ...
%                 alpha*(E(choice((condI*nTrialsPerCond+trialI))+1)-result(condI*nTrialsPerCond+trialI));        
        else
            TDerr=[TDerr; 0.0];
        end
        Elist=[Elist; E];
        %Stochastic choice rule: Softmax or exponentiated Luce choice rule
%        P = [P; (.0001+exp(E(1)*theta))/((sum(exp(E*theta)))+.0001)];
    end %for trialI=1:size(outcome,1)
    Elist=Elist(1:end-1,:);
    PwlList=[PwlList;Pwl];
end %for condI=1:size(condition,2)

%Evaluate fit
%drop first choice for each cond because we can't predict it
%   choice=[choice(2:nTrialsPerCond); choice(nTrialsPerCond+2:2*nTrialsPerCond); choice(2*nTrialsPerCond+2:end)];
%   P=[P(2:nTrialsPerCond,:); P(nTrialsPerCond+2:2*nTrialsPerCond,:); P(2*nTrialsPerCond+2:end,:)]; %use this P-trimmer if P is assigned prior to E
%drop last P for each cond because it is a prediction for the Next choice
%P=[P(1:nTrialsPerCond-1,:); P(nTrialsPerCond+1:2*nTrialsPerCond-1,:); P(2*nTrialsPerCond+1:end-1,:)]; 

%choice(find(choice<0))=NaN;
%choice = [1-choice choice];
%P = [P 1-P];



% if(plot_flag)
%     figure(99);
%     hold on;
%     subplot(3,1,1);plot(P(1:end/2,:),'LineWidth',2);title('1st block/condition');
%     subplot(3,1,2);hold on;plot(P(end/2+1:2*end/2,:),'LineWidth',2);title('2nd block/condition');
%     suptitle('Probability of choosing ');
% end
% 
% if(plot_flag)
%     figure(98)
%     hold on;
%     subplot(3,1,1);plot(Elist(1:end/2,:),'LineWidth',2);title('1st block/condition');
%     subplot(3,1,2);hold on;plot(Elist(end/2+1:2*end/2,:),'LineWidth',2);title('2nd block/condition');
%     suptitle('Expected payoff (Value)');
% end
% 
% if(plot_flag)
%     figure(97);
%     hold on;
%     subplot(3,1,1);plot(TDerr(1:end/2,:),'LineWidth',2);title('1st block/condition');
%     subplot(3,1,2);hold on;plot(TDerr(end/2+1:2*end/2,:),'LineWidth',2);title('2nd block/condition');
%     suptitle('Error signal');
% end

Pcombi=P*gamma + (1-gamma)*PwlList;

POutput=P;
P=Pcombi;
P=P(isfinite(choice),:);
% Elist=Elist(isfinite(choice),:);
% rewTime=rewTime(isfinite(choice),:);
% cueTime=cueTime(isfinite(choice),:);
ChOutput=choice;

choice=choice(isfinite(choice));
% outcome=outcome(isfinite(choice),:);

P=diag(P(:,choice+1));

%SSE
SSE = (nansum(nansum((choice - P).^2)));

%MLE
%small manipulation to keep from taking log of 0
P = .9998.*P + .0001; 
choice = .9998.*choice + .0001; 
% logLik = log(P);
% cdf('beta',(alpha+0.01),0.0904,0.4931)-cdf('beta',(alpha-0.01),0.0904,0.4931)
% cdf('beta',(theta+0.01),0.9279,0.2755)-cdf('beta',(theta-0.01),0.9279,0.2755)

% logLik =log(P.*(abs(cdf('beta',(alpha+0.005),1.6233,2.7364)-cdf('beta',(alpha-0.005), 1.6233,2.7364))));%.*abs(cdf('beta',(theta/10+0.005),0.6072,0.6627)-cdf('beta',(theta/10-0.005),0.6072,0.6627))));
logLik = log(P);%.*(abs(cdf('beta',(alpha+0.005),1.3298,0.9085)-cdf('beta',(alpha-0.005), 1.3298,0.9085))).*abs(cdf('beta',(theta+0.005),3.0898,5.1692)-cdf('beta',(theta-0.005),3.0898,5.1692));
%logLik = log(P.*(pdf('beta',alpha,2.7346,6.3439)*pdf('beta',1/theta,1.9047,109.8151))).*(choice); %for RewPun fit
neg2TLogLik = -2*nansum((nansum(logLik))); 

if(plot_flag)
    figure(100);
    suptitle(['Goodness of fit ' num2str(neg2TLogLik);]);
    while (size(POutput,1)<60)
        POutput=[POutput; zeros(1,size(POutput,2))];
    end
    
    while (size(Elist,1)<60)
        Elist=[Elist; zeros(1,size(Elist,2))];
    end
    
    while (size(TDerr,1)<60)
        TDerr=[TDerr; zeros(1,size(TDerr,2))];
    end
    
    while (size(rewTime,1)<60)
        rewTime=[rewTime; zeros(1,size(time,2))];
    end
    while (size(outcome,1)<60)
        outcome=[outcome; zeros(1,size(time,2))];
    end
    while (size(cueTime,1)<60)
        cueTime=[cueTime; zeros(1,size(time,2))];   
    end
    
%     dlmwrite(['modelFits/oppPunMeanSubj' num2str(subject) '.txt'],[POutput ChOutput Elist cueTime TDerr outcome rewTime],'newline','pc');
end

if max(alpha < 0) || max(alpha > 1) || max(theta < 0.01) || max(theta > 1000)
    error = 100000000;
else
    error = neg2TLogLik;
    %error = SSE;
end
