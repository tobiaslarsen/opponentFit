dbstop if error;

HC=[2 6 8 15 19 21 26 28:34 35 37:38 40:41 43];%  6 19 21 35
Prob=[5 7 9 10 12 18 20 22 24 36 42];
Path=[4 11 13 14 16 17 25 27 39]; %4
PPG=sort([Prob Path]);
ALL=sort([HC PPG]);

iter=1;
parListPHCD=NaN(43*iter,3);
goodListPHCD=NaN(43*iter,1);
parListPPrD=NaN(43*iter,3);
goodListPPrD=NaN(43*iter,1);
parListPPPG=NaN(43*iter,3);
goodListPPPG=NaN(43*iter,1);

% parListRInd=NaN(43*iter,3);
% goodListRInd=NaN(43*iter,1);

parListNHC=NaN(43*iter,3);
goodListNHC=NaN(43*iter,1);

% parListNInd=NaN(43*iter,3);
% goodListNInd=NaN(43*iter,1);

parListPrD=NaN(43*iter,3);
goodListPrD=NaN(43*iter,1);
parListPaD=NaN(43*iter,3);
goodListPaD=NaN(43*iter,1);
parListPHC=NaN(43*iter,3);
goodListPHC=NaN(43*iter,1);
parListPPr=NaN(43*iter,3);
goodListPPr=NaN(43*iter,1);
parListPPa=NaN(43*iter,3);
goodListPPa=NaN(43*iter,1);
    
% gambHierFit([HC],1);
% [p,g]=gambfit(PPG,2)
% for i=[2 4:40]
ind=1;
for j=0
for i=ALL
    for k=1:20
        [p,g]=gambfit(i,2);
        parListPPr(ind,:)=p;
        goodListPPr(ind)=g;
        ind=ind+1;
    end
%     parListRHCD(j*max(ALL)+i,:)=p;
%     goodListRHCD(j*max(ALL)+i)=g;
end
end
% 
% for j=0
% for i=[PPG]
%     [p,g]=gambfit(i,1);
% %     parListPPPG(j*max(ALL)+i,:)=p;
% %     goodListPPPG(j*max(ALL)+i)=g;
% end
% end
% 
% for j=0
% for i=[Path]
%     [p,g]=gambfit(i,1);
%     parListPaD(j*max(ALL)+i,:)=p;
%     goodListPaD(j*max(ALL)+i)=g;
% end
% end
% 
% for j=0
% for i=[ALL]
%     [p,g]=gambfit(i,5);
% %     parList(j*max(ALL)+i,:)=p;
% %     goodList(j*max(ALL)+i)=g;
% end
% end

% 
% for i=[2 4:20]
%     gambfit(i,2);
% end


% for i=[2 4:20]
%     gambfit(i,3);
% end