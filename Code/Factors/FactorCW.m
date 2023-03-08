%Factor Model 
set(0,'defaulttextinterpreter','latex')

%I first load the required data. I follow Altavilla. He uses changes in the
%1,3,6 month yields and the 1,2,5,10 year yields. Whenever long term yields
%are not available he uses the German ones.


acr = readtable('Alta.xlsx','Sheet','Press Conference Window'); %name as per Altavilla Press Conference
dates_alta = (((acr.date)));

%Conference window:
ois1m_cw = acr.OIS_1M;
ois3m_cw = acr.OIS_3M;
ois6m_cw = acr.OIS_6M;
ois1y_cw = acr.OIS_1Y;
deu2y_cw = acr.DE2Y(1:187);
deu5y_cw = acr.DE5Y(1:187);
deu10y_cw = acr.DE10Y(1:187);

%I use only deutsch rates prior Aug2011 and afterwrds the
%corresponfing OIS rates.

ois2y_cw = acr.OIS_2Y(188:end);
ois5y_cw = str2double(acr.OIS_5Y(188:end));
ois10y_cw = str2double(acr.OIS_10Y(188:end));


ois2y_cw = [deu2y_cw;ois2y_cw];
ois5y_cw = [deu5y_cw; ois5y_cw];
ois10y_cw = [deu10y_cw;ois10y_cw];


%I then delete all those dates for which there is no information
%available for at least one variable of interest. 

acr = table(dates_alta, ois1m_cw,ois3m_cw,ois6m_cw,ois1y_cw,ois2y_cw,ois5y_cw,ois10y_cw, 'VariableNames', {'Date','OIS_1M','OIS_3M','OIS_6M','OIS_1Y', 'OIS_2Y','OIS_5Y', 'OIS_10Y'}); 



acr= acr(~any(ismissing(acr),2),:);


%The NaN is also excludes the Sept. 11 announcements
%(2001/09/17) and the 50% rate cut for Bank (2008/10/08) which is
%considered to be an outlier.

%Altavilla et al also remove (2008/11/06) which is not done by the remove
%NaN so I do it manually. This is observation number 112. 
 acr(112,:) = [];



%writetable(acr,'ACR.csv','Delimiter',',','QuoteStrings',1)



%I extract them again this time considering only 2002 onwards and before
%2020.
t1 = 35;
t2 = 224;
dates_alta = datestr(acr.Date((t1:t2)));
dates_alta = datetime(dates_alta,'Format','dd-MM-yyyy');
ois1m_cw = acr.OIS_1M(t1:t2);
ois3m_cw = acr.OIS_3M(t1:t2);
ois6m_cw = acr.OIS_6M(t1:t2);
ois1y_cw = acr.OIS_1Y(t1:t2);
ois2y_cw = acr.OIS_2Y(t1:t2);
ois5y_cw = acr.OIS_5Y(t1:t2);
ois10y_cw = acr.OIS_10Y(t1:t2);

%standarisation

av_ois1m_cw = mean(ois1m_cw);
sd_ois1m_cw = std(ois1m_cw);
std_ois1m_cw = (ois1m_cw - av_ois1m_cw)*(1/sd_ois1m_cw);  %I call it like the variable but standarised


av_ois3m_cw = mean(ois3m_cw);
sd_ois3m_cw = std(ois3m_cw);
std_ois3m_cw = (ois3m_cw - av_ois3m_cw)*(1/sd_ois3m_cw);



av_ois6m_cw = mean(ois6m_cw);
sd_ois6m_cw = std(ois6m_cw);
std_ois6m_cw = (ois6m_cw - av_ois6m_cw)*(1/sd_ois6m_cw);


av_ois1y_cw = mean(ois1y_cw);
sd_ois1y_cw = std(ois1y_cw);
std_ois1y_cw = (ois1y_cw - av_ois1y_cw)*(1/sd_ois1y_cw);


av_ois2y_cw = mean(ois2y_cw);
sd_ois2y_cw = std(ois2y_cw);
std_ois2y_cw = (ois2y_cw - av_ois2y_cw)*(1/sd_ois2y_cw);


av_ois5y_cw = mean(ois5y_cw);
sd_ois5y_cw = std(ois5y_cw);
std_ois5y_cw = (ois5y_cw - av_ois5y_cw)*(1/sd_ois5y_cw);


av_ois10y_cw = mean(ois10y_cw);
sd_ois10y_cw = std(ois10y_cw);
std_ois10y_cw = (ois10y_cw - av_ois10y_cw)*(1/sd_ois10y_cw);


%the standarised data:
z =[std_ois1m_cw, std_ois3m_cw, std_ois6m_cw, std_ois1y_cw, std_ois2y_cw, std_ois5y_cw, std_ois10y_cw ];

%the variance covariance marix

covx = z'*z;
[V,D,W] = eig(covx);

%notice the last three eigenvalues are the largest. we keep these
%store the eigenvectors. flip the order around so that the most important drivrere is first
pc = fliplr(W(:,5:7));  


D = diag((D));
D = flip(D(5:7));  %loading weights, i.e. the eigenvalues associated with the largest 3 pc. Once again reversing order
D = diag(1./sqrt(D));


%creating the factors and normalising them as in GSS.
F = (z*pc);

F(:,1) = F(:,1)/std(F(:,1));
F(:,2) = F(:,2)/std(F(:,2));
F(:,3) = F(:,3)/std(F(:,3));

 
%loadings;
%for regression output better to use R. 
[~,~,coeff]=hac(fitlm(F, std_ois1m_cw));
coeffois1m = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois3m_cw));
coeffois3m = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois6m_cw));
coeffois6m = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois1y_cw));
coeffois1y = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois2y_cw));
coeffois2y = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois5y_cw));
coeffois5y = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois10y_cw));
coeffois10y = coeff(2:4);

%creating the loadings. 

lam = [coeffois1m,coeffois3m,coeffois6m,coeffois1y,coeffois2y,coeffois5y,coeffois10y];
figure()
plot(lam')
legend('Timing','Path','QE')


%Data prior to the crisis:
F_cwe = F(1:75,:);

%%Altavilla Optimisation

x0 = ones(3); %guessed values
u = ['u11'; 'u12'; 'u13'; 'u21'; 'u22'; 'u23'; 'u31'; 'u32'; 'u33']; %the variables I optmise over
nonlcon = @altarot;    %I set the nonlinear constraints
%since there are no other constraints:
A = []; 
b = [];
Aeq = [];
beq = [];
lb = [];
ub = [];
xalta = fmincon(@(u) obj_altavilla(F_cwe, u(3),u(6),u(9)), x0, A,b,Aeq,beq,lb,ub, @(u) nonlcon(lam, u(1),u(2),u(3), u(4), u(5), u(6), u(7), u(8), u(9)));

%Given x alta is arranged in a matrix of dimension 3 by 3 where elements
%are filled columnwise first, I need to take the transpose so that its
%correctly ordered


%candidate rotation matrix
xalta = xalta';

%quick check: is it orthonormal?
xalta*xalta';
xaltar=ones(size(xalta));
%playing with signs
xaltar(:,1) = xalta(:,1);
xaltar(:,2) = xalta(:,2);
xaltar(:,3) = -1*xalta(:,3);

%rotated loadings
loadings = xaltar'*lam;

%Figure depicting the factors loadings. 
figure()
subplot(1,3,1)
plot(loadings(1,:)')
xticklabels({'OIS_{1M}','OIS_{3M}','OIS_{6M}','OIS_{1Y}','OIS_{2Y}','OIS_{5Y}','OIS_{10Y}','interpreter', 'latex'})
title('Timing Factor Loadings')
xlabel('OIS Maturity') 
ylabel('Loading')
subplot(1,3,2)
plot(loadings(2,:)')
xticklabels({'OIS_{1M}','OIS_{3M}','OIS_{6M}','OIS_{1Y}','OIS_{2Y}','OIS_{5Y}','OIS_{10Y}','interpreter', 'latex'})
title('Path Factor Loadings')
xlabel('OIS Maturity') 
ylabel('Loading') 
subplot(1,3,3)
plot(loadings(3,:)') 
xticklabels({'OIS_{1M}','OIS_{3M}','OIS_{6M}','OIS_{1Y}','OIS_{2Y}','OIS_{5Y}','OIS_{10Y}','interpreter', 'latex'})
title('QE Factor Loadings')
xlabel('OIS Maturity') 
ylabel('Loading') 



%Rotating original factor scoares.
nnF = F*xaltar;

%factors are already loading positively on the required rates. No further
%transformation necessary

%For forward guidance surprises:

FG_con = nnF(:,2);

figure()
plot(dates_alta, FG_con)
title('Conference Window: Forward Guidance Factor')
xlabel('Date') 

%Regressions of the different instrument on the factors. Needed for a
%figure I dont use. 

[~,se,coeff]= hac(fitlm(nnF, std_ois1m_cw));
coeffois1m = coeff(2:4);
se1m = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois3m_cw));
coeffois3m = coeff(2:4);
se3m = se(2:4);


[~,se,coeff]=hac(fitlm(nnF, std_ois6m_cw));
coeffois6m = coeff(2:4);
se6m = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois1y_cw));
coeffois1y = coeff(2:4);
se1y = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois2y_cw));
coeffois2y = coeff(2:4);
se2y = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois5y_cw));
coeffois5y = coeff(2:4);
se5y = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois10y_cw));
coeffois10y = coeff(2:4);
se10y = se(2:4);

T = size(z,1);

lam = [coeffois1m,coeffois3m,coeffois6m,coeffois1y,coeffois2y,coeffois5y,coeffois10y];
up = [coeffois1m+1.96*se1m, coeffois3m+1.96*se3m,coeffois6m+1.96*se6m,coeffois1y+1.96*se1y,coeffois2y+1.96*se2y, coeffois5y+1.96*se5y, coeffois10y+1.96*se10y];
down= [coeffois1m-1.96*se1m, coeffois3m-1.96*se3m,coeffois6m-1.96*se6m,coeffois1y-1.96*se1y,coeffois2y-1.96*se2y, coeffois5y-1.96*se5y, coeffois10y-1.96*se10y];


figure()
subplot(1,3,1)
hold on 
inBetween = [down(1,:), fliplr(up(1,:))];
fill([1:7, fliplr(1:7)], inBetween, 'k','FaceColor',[0.7 0.7 0.9],'LineStyle','none');
plot(lam(1,:)','b')
xlab = {'OIS_{1M}','OIS_{3M}','OIS_{6M}','OIS_{1Y}','OIS_{2Y}','OIS_{5Y}','OIS_{10Y}'};
set(gca, 'XTickLabels', xlab)
title('Timing Factor Loadings')
xlabel('OIS Maturity') 
ylabel('Loading')
hold off

subplot(1,3,2)
hold on 
inBetween = [down(2,:), fliplr(up(2,:))];
fill([1:7, fliplr(1:7)], inBetween, 'k','FaceColor',[0.7 0.7 0.9],'LineStyle','none');
plot(lam(2,:)','b')
hold off
xlab = {'OIS_{1M}','OIS_{3M}','OIS_{6M}','OIS_{1Y}','OIS_{2Y}','OIS_{5Y}','OIS_{10Y}'};
set(gca, 'XTickLabels', xlab)
title('Path Factor Loadings')
xlabel('OIS Maturity') 
ylabel('Loading') 

subplot(1,3,3)
hold on 
inBetween = [down(3,:), fliplr(up(3,:))];
fill([1:7, fliplr(1:7)], inBetween, 'k','FaceColor',[0.7 0.7 0.9],'LineStyle','none');
plot(lam(3,:)','b') 
xlab = {'OIS_{1M}','OIS_{3M}','OIS_{6M}','OIS_{1Y}','OIS_{2Y}','OIS_{5Y}','OIS_{10Y}'};
set(gca, 'XTickLabels', xlab)
title('QE Factor Loadings')
xlabel('OIS Maturity') 
ylabel('Loading') 




%Figure depiciting the factor scores for forward guidance:

figure()
plot(dates_alta, FG_con,'LineWidth',2.0)
title('Conference Window: Identified Forward Guidance Surprises','fontsize',16, 'interpreter','latex')
xlabel('Date','fontsize',16,'interpreter','latex') 



%Creating tables:
nnF = array2table(nnF);
dates_alta = array2table((dates_alta));
Factors = [dates_alta, nnF];
Factors.Properties.VariableNames={'Date', 'TMP', 'FG', 'QE'};


%writetable(Factors,'FactorsCW.csv','Delimiter',',','QuoteStrings',true)



z = array2table(z);
factor_R_CW = [dates_alta, nnF,z];
factor_R_CW.Properties.VariableNames={'Date', 'TMP', 'FG', 'QE','OIS_1M','OIS_3M','OIS_6M','OIS_1Y','OIS_2Y','OIS_5Y','OIS_10Y'};

%writetable(factor_R_CW,'factor_R_CW.csv','Delimiter',',','QuoteStrings',true);

%Provided the monetary event code for the factors is also run, then the
%following creates a graph comparing factor scores: 
figure()
subplot(2,1,1)
plot(dates_alta, FG_con)
title('Conference Window: Forward Guidance Factor','fontsize',16,'interpreter','latex')
xlabel('Date','fontsize',16,'interpreter','latex')
subplot(2,1,2)
plot(dates_alta_mon, FG_mon)
title('Monetary Event Window: Forward Guidance Factor','fontsize',16,'interpreter','latex')
xlabel('Date','fontsize',16,'interpreter','latex')