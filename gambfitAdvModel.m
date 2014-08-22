function [parms, goodness] = gambfitAdvModel(subjectNo,condition)
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
x0(1)=rand; x0(2)=rand; x0(3)=rand;

%%%Function call to hill-climbing (search) algorithm
[parms goodness exitFlag] = fminsearchbnd(@(x0) rlfitter(x0,outcome,choice,result,rewTime,cueTime,condition,0), x0,[0.05 0.01 -1],[1 10 1]); %, options);

% x0=parms;
% rlfitter(x0,outcome,choice,result,rewTime,cueTime,condition,1);
% parms=choice;
% goodness=outcome;

            
%Model with built-in fitness function
function error = rlfitter(parms, outcome, choice, result, rewTime, cueTime, condition, plot_flag)
global subject;
nTrialsPerCond=30; 
alpha = parms(1);
theta = parms(2);
gamma=1;%parms(3);
neut_val=0;

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
        
        if(plot_flag)
            P;
        end
        
        %Model: Advantage learning 
        if(choice((condI*nTrialsPerCond+trialI))>=0)
%            ADVerr = rew - chosen value
            
        else
            TDerr=[TDerr;0.0];
        end
        

        
        Elist=[Elist; E];
        %Stochastic choice rule: Softmax or exponentiated Luce choice rule
%        P = [P; (.0001+exp(E(1)*theta))/((sum(exp(E*theta)))+.0001)];
    end %for trialI=1:size(outcome,1)
    Elist=Elist(1:end-1,:);
%     PwlList=[PwlList;Pwl];
end %for condI=1:size(condition,2)


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
