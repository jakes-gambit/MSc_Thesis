%Testing for the Number of Factors. Follows GSS.

%Factor Model 
set(0,'defaulttextinterpreter','latex')

amw = readtable('Alta.xlsx','Sheet','Monetary Event Window'); %name as per Altavilla Press Conference
dates_alta = datetime(amw.date,'Format','dd-MM-yyyy');


%Monetary Window Rates
ois1m_mw = amw.OIS_1M;
ois3m_mw = amw.OIS_3M;
ois6m_mw = amw.OIS_6M;
ois1y_mw = amw.OIS_1Y;
deu2y_mw = amw.DE2Y(1:187);
deu5y_mw = amw.DE5Y(1:187);
deu10y_mw = amw.DE10Y(1:187);


%I use only deutsch rates mwe Aug2011 and afterwrds the
%corresponfing OIS rates.

ois2y_mw = amw.OIS_2Y(188:end);
ois5y_mw = str2double(amw.OIS_5Y(188:end));
ois10y_mw = str2double(amw.OIS_10Y(188:end));


ois2y_mw = [deu2y_mw;ois2y_mw];
ois5y_mw = [deu5y_mw; ois5y_mw];
ois10y_mw = [deu10y_mw;ois10y_mw];

%I first delete all those dates for which there is no information
%available for at least one variable of interest. 

amw = table(dates_alta, ois1m_mw,ois3m_mw,ois6m_mw,ois1y_mw,ois2y_mw,ois5y_mw,ois10y_mw, 'VariableNames',{'Date','OIS_1M','OIS_3M','OIS_6M','OIS_1Y','OIS_2Y','OIS_5Y','OIS_10Y'}); 
amw= amw(~any(ismissing(amw),2),:);

%03 of Jan 2002 to end of 2019 period
amw = amw(72:end-4,:);


dates_alta = datestr(amw.Date);
dates_alta = datetime(dates_alta,'Format','dd-MM-yyyy');
dates_alta_mon = dates_alta; %used for graph comparing fg factor in monetary and in conference window.


ois1m_mw = amw.OIS_1M;
ois3m_mw = amw.OIS_3M;
ois6m_mw = amw.OIS_6M;
ois1y_mw = amw.OIS_1Y;
ois2y_mw = amw.OIS_2Y;
ois5y_mw = amw.OIS_5Y;
ois10y_mw = amw.OIS_10Y;


av_ois1m_mw = mean(ois1m_mw);
sd_ois1m_mw = std(ois1m_mw);
std_ois1m_mw = (ois1m_mw - av_ois1m_mw)*(1/sd_ois1m_mw);  %I call it like the variable but standarised


av_ois3m_mw = mean(ois3m_mw);
sd_ois3m_mw = std(ois3m_mw);
std_ois3m_mw = (ois3m_mw - av_ois3m_mw)*(1/sd_ois3m_mw);



av_ois6m_mw = mean(ois6m_mw);
sd_ois6m_mw = std(ois6m_mw);
std_ois6m_mw = (ois6m_mw - av_ois6m_mw)*(1/sd_ois6m_mw);


av_ois1y_mw = mean(ois1y_mw);
sd_ois1y_mw = std(ois1y_mw);
std_ois1y_mw = (ois1y_mw - av_ois1y_mw)*(1/sd_ois1y_mw);


av_ois2y_mw = mean(ois2y_mw);
sd_ois2y_mw = std(ois2y_mw);
std_ois2y_mw = (ois2y_mw - av_ois2y_mw)*(1/sd_ois2y_mw);


av_ois5y_mw = mean(ois5y_mw);
sd_ois5y_mw = std(ois5y_mw);
std_ois5y_mw = (ois5y_mw - av_ois5y_mw)*(1/sd_ois5y_mw);


av_ois10y_mw = mean(ois10y_mw);
sd_ois10y_mw = std(ois10y_mw);
std_ois10y_mw = (ois10y_mw - av_ois10y_mw)*(1/sd_ois10y_mw);



z =[std_ois1m_mw, std_ois3m_mw, std_ois6m_mw, std_ois1y_mw, std_ois2y_mw, std_ois5y_mw, std_ois10y_mw ];

%the variance covariance marix

covx = z'*z;
[V,D,W] = eig(covx);

%notice the last three eigenvalues are the largest. we keep these
%store the eigenvectors. flip the order around so that the most important drivrere is first
pc = fliplr(W(:,5:7));  


D = diag((D));
D = flip(D(5:7));  %loading weights, i.e. the eigenvalues associated with the largest 3 pc. Once again reversing order
D = diag(1./sqrt(D));

%create the mwincipal components, recall these are the 'latent variables'
F = (z*pc);

F(:,1) = F(:,1)/std(F(:,1));
F(:,2) = F(:,2)/std(F(:,2));
F(:,3) = F(:,3)/std(F(:,3));



%loadings;
%for regression output better to use R. 
[~,~,coeff]=hac(fitlm(F, std_ois1m_mw));
coeffois1m = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois3m_mw));
coeffois3m = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois6m_mw));
coeffois6m = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois1y_mw));
coeffois1y = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois2y_mw));
coeffois2y = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois5y_mw));
coeffois5y = coeff(2:4);

[~,~,coeff]=hac(fitlm(F, std_ois10y_mw));
coeffois10y = coeff(2:4);

%creating the loadings. 

lam = [coeffois1m,coeffois3m,coeffois6m,coeffois1y,coeffois2y,coeffois5y,coeffois10y];
figure()
plot(lam')
legend('Timing','Path','QE')







figure()
plot(lam')
legend('Timing','Path','QE')


%Data prior to crisis
F_mwe = F(1:80,:);


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
xalta = fmincon(@(u) obj_altavilla(F_mwe, u(3),u(6),u(9)), x0, A,b,Aeq,beq,lb,ub, @(u) nonlcon(lam, u(1),u(2),u(3), u(4), u(5), u(6), u(7), u(8), u(9)));




% rotation matrix
xalta = xalta';

%rotated loadings:
loadings = xalta'*lam;


figure()
plot(loadings')
xticklabels({'OIS_1M','OIS_3M','OIS_6M','OIS_1Y','OIS_2Y','OIS_5Y','OIS_10Y'})
legend('Timing','Path','QE')


%rotated factors:
nnF = F*xalta;


[~,se,coeff]= hac(fitlm(nnF, std_ois1m_mw));
coeffois1m = coeff(2:4);
se1m = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois3m_mw));
coeffois3m = coeff(2:4);
se3m = se(2:4);


[~,se,coeff]=hac(fitlm(nnF, std_ois6m_mw));
coeffois6m = coeff(2:4);
se6m = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois1y_mw));
coeffois1y = coeff(2:4);
se1y = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois2y_mw));
coeffois2y = coeff(2:4);
se2y = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois5y_mw));
coeffois5y = coeff(2:4);
se5y = se(2:4);

[~,se,coeff]=hac(fitlm(nnF, std_ois10y_mw));
coeffois10y = coeff(2:4);
se10y = se(2:4);

T = size(z,1);

lam = [coeffois1m,coeffois3m,coeffois6m,coeffois1y,coeffois2y,coeffois5y,coeffois10y];
up = [coeffois1m+1.96*se1m, coeffois3m+1.96*se3m,coeffois6m+1.96*se6m,coeffois1y+1.96*se1y,coeffois2y+1.96*se2y, coeffois5y+1.96*se5y, coeffois10y+1.96*se10y];
down= [coeffois1m-1.96*se1m, coeffois3m-1.96*se3m,coeffois6m-1.96*se6m,coeffois1y-1.96*se1y,coeffois2y-1.96*se2y, coeffois5y-1.96*se5y, coeffois10y-1.96*se10y];

%Figure depicting the factors loadings. 

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


%forward guidance surprises:
FG_mon = nnF(:,2);

figure()
plot(dates_alta, FG_mon)
title('Monetary Event Window: Forward Guidance Factor')
xlabel('Date') 

%creating tables:

nnF = array2table(nnF);
dates_alta = array2table((dates_alta));
Factors = [dates_alta, nnF];
Factors.Properties.VariableNames={'Date', 'TMP', 'FG', 'QE'};

z = array2table(z);
factor_R_MW = [dates_alta, nnF,z];
factor_R_MW.Properties.VariableNames={'Date', 'TMP', 'FG', 'QE','OIS_1M','OIS_3M','OIS_6M','OIS_1Y','OIS_2Y','OIS_5Y','OIS_10Y'};
%writetable(factor_R_MW,'factor_R_MW.csv','Delimiter',',','QuoteStrings',true);



