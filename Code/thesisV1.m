%Forward Guidance in Unconventional Times: The Euro-Area Experience
%Jake Argana
%Code to obtain main results. 

%Data and Time series extraction: 

%Inflation and Spreads

inflation_exp_data = readtable('anticipation_data.csv');
start = 58;
inflation_exp_data = inflation_exp_data(start:end,:);


%exp_inf_1 = inflation_exp_data.x1YExpInf;
exp_inf_3 = inflation_exp_data.x3YExpInf;
ITDEU_spread = inflation_exp_data.ITDEU_spread;
%mc = inflation_exp_data.MC;

%For other variables
start = 15;
monthlyvars2 = readtable('monthlydata2.CSV');
monthlyvars2 = monthlyvars2(start:end,:);
EUVars = readtable('EU.CSV');
EUVars = EUVars(start:end,:);
 

EU_HICP = log(EUVars.HICP);
EU_IP = log(EUVars.IP);
EU_comm = log(EUVars.UseWeighted_NonFood);
EU_urate = log(EUVars.URATE);
EU_exch = log(EUVars.EXCH);


EONIA =monthlyvars2.EONIA;
R01 = monthlyvars2.R01;
R10 = monthlyvars2.R10;
R02 = monthlyvars2.R02;
CISS = monthlyvars2.CISS;
sovCISS = monthlyvars2.sovCISS;
EUROSTOXX = log(monthlyvars2.EUROSTOXX);
func = log(monthlyvars2.VSTOXX);







euroarea_corpspread1 = monthlyvars2.spr_nfc_dom_ea;
euroarea_corpspread2 = monthlyvars2.spr_nfc_bund_ea;






%Proxy Variable
%simple sum version:
FG_CW = monthlyvars2.FG_CW;
%scaled version
sFG_CW = monthlyvars2.SFG_CW; 


%VAR Specification:

y = [EU_IP, EU_HICP, R02, exp_inf_3 , ITDEU_spread, euroarea_corpspread2];
spec.p = 4;
spec.deter=1;
spec.impR =0;
spec.lagaugmentation=0;
spec.carstenIRF=0;

JakeVAR = rVARestimation(y, spec);


%LAG ORDER SELECTION
foptions.pmax =12;
foptions.DeterTerms =1;
ic_obj=ic_lag(y,foptions);

lagy= lagrange(3, JakeVAR.U_res, JakeVAR.Z, spec.p);

k = size(y,2);
sz=k;
for i=1:k  %this determines which variables response we are plotting
subplot(2,3,i)
hold on
autocorr(JakeVAR.U_res(i,:))
end


%Assessing the instrument's strength:

specprox.p=spec.p;
p=specprox.p;
specprox.deter =1;
specprox.pos = 3;
specprox.lagaugmentation =0;
specprox.shocks=1;
specprox.c= 9.98;

p4 = proxycomplete(y,FG_CW,specprox);
effectivedates = monthlyvars2.Date(p+1:end);

figure()
plot(effectivedates, p4.shocks, 'r','LineWidth',2.0)
title('Forward Guidance Shock Sequence','interpreter', 'latex','fontsize',16)
xlabel('Date', 'interpreter','latex', 'fontsize',16)



%Structural Analysis

specprox.p=spec.p; 
specprox.max = 50;
specprox.bs =9999;
specprox.level1 =0.90;
specprox.level2 = 0.80;
specprox.deter =1;
specprox.length = 6;%REMEMBER THE CONDITION Nl>=T.
specprox.lagaugmentation = 0;
specprox.pos=3;
specprox.IRF =1;

    
pp = irfboots(y, FG_CW, specprox);


%OUTPUT FOR IRFS: the function already returns IRFs but not with titles
%etc

hall_low1 = pp.hall_low1;
hall_low2 = pp.hall_low2;
hall_up1 = pp.hall_up1;
hall_up2 = pp.hall_up2;
sMA_coef = pp.sMA_coef;
max = 50;
k=6;



figure()
subplot(2,3,1)
hold on
plot(hall_low1(1,:),'k')
plot(hall_up1(1,:),'k')
inBetween = [hall_low1(1,:), fliplr(hall_up1(1,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(1,:),'k')
plot(hall_up2(1,:),'k')
inBetween2 = [hall_low2(1,:), fliplr(hall_up2(1,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(1,1:max),'r')
yline(0,'k')
title('FG \rightarrow  ln(Ind. Prod)','Interpreter','tex')
hold off
i=2;
subplot(2,3,i)
hold on
plot(hall_low1(i,:),'k')
plot(hall_up1(i,:),'k')
inBetween = [hall_low1(i,:), fliplr(hall_up1(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low2(i,:), fliplr(hall_up2(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow  ln(HICP)','Interpreter','tex')
i=3;
subplot(2,3,i)
hold on
plot(hall_low1(i,:),'k')
plot(hall_up1(i,:),'k')
inBetween = [hall_low1(i,:), fliplr(hall_up1(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low2(i,:), fliplr(hall_up2(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow  2-year German Govt. Yield','Interpreter','tex')
i=4;
subplot(2,3,i)
hold on
plot(hall_low1(i,:),'k')
plot(hall_up1(i,:),'k')
inBetween = [hall_low1(i,:), fliplr(hall_up1(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low2(i,:), fliplr(hall_up2(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow  3-Year Exp. Inflation','Interpreter','tex')
i=5;
subplot(2,3,i)
hold on
plot(hall_low1(i,:),'k')
plot(hall_up1(i,:),'k')
inBetween = [hall_low1(i,:), fliplr(hall_up1(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low2(i,:), fliplr(hall_up2(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow IT-DEU Bond Spread','Interpreter','tex')
i=6;
subplot(2,3,i)
hold on
plot(hall_low1(i,:),'k')
plot(hall_up1(i,:),'k')
inBetween = [hall_low1(i,:), fliplr(hall_up1(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low2(i,:), fliplr(hall_up2(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow Corp. Bond Spread','Interpreter','tex')


%Orthogonalised Surprises and IRFs


FG_orth = readtable('orthgonalised_surprises.csv');
uFG_orth = FG_orth.FG_CW;
sFG_orth = FG_orth.scaled_FG_CW;

specprox.p=spec.p; 
p=specprox.p;
specprox.deter =1;
specprox.pos = 3;
specprox.lagaugmentation =0;
specprox.shocks=1;
specprox.c= 9.98;


%Instrument's strength:
p5 = proxycomplete(y,uFG_orth(4:end,:),specprox);

effectivedates = monthlyvars2.Date(p+1:end);




figure()
box on
hold on 
plot(effectivedates, p4.shocks, 'r','LineWidth',2.0)
plot(effectivedates, p5.shocks, 'k--','LineWidth',0.5)
title('Orthogonalised  Shocks vs. Non-Orthogonalised Shocks','interpreter', 'latex','fontsize',16)
xlabel('Date', 'interpreter','latex', 'fontsize',16)
hold off


figure()
hold on 
subplot(2,1,1)
plot(effectivedates, p4.shocks, 'r','LineWidth',2.0)
subplot(2,1,2)
plot(effectivedates, p5.shocks, 'b','LineWidth',2.0)



%Re-estimation of IRFs with new Proxy Variable

specprox.p=spec.p; 
specprox.max = 50;
specprox.bs =9999;
specprox.level1 =0.90;
specprox.level2 = 0.80;
specprox.deter =1;
specprox.length = 6;%REMEMBER THE CONDITION Nl>=T.
specprox.lagaugmentation = 0;
specprox.pos=3;
specprox.IRF =1;

pp = irfboots(y, uFG_orth(4:end,:), specprox);

hall_low11 = pp.hall_low1;
hall_low22 = pp.hall_low2;
hall_up11 = pp.hall_up1;
hall_up22 = pp.hall_up2;
sMA_coef_orth = pp.sMA_coef;
max = 50;
k=6;


figure()
subplot(2,3,1)
hold on
plot(hall_low11(1,:),'k')
plot(hall_up1(1,:),'k')
inBetween = [hall_low11(1,:), fliplr(hall_up11(1,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low22(1,:),'k')
plot(hall_up22(1,:),'k')
inBetween2 = [hall_low22(1,:), fliplr(hall_up22(1,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef_orth(1,1:max),'r')
yline(0,'k')
title('FG \rightarrow  ln(Ind. Prod)','Interpreter','tex')
hold off
i=2;
subplot(2,3,i)
hold on
plot(hall_low11(i,:),'k')
plot(hall_up11(i,:),'k')
inBetween = [hall_low11(i,:), fliplr(hall_up11(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low22(i,:),'k')
plot(hall_up22(i,:),'k')
inBetween2 = [hall_low22(i,:), fliplr(hall_up22(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef_orth(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow  ln(HICP)','Interpreter','tex')
i=3;
subplot(2,3,i)
hold on
plot(hall_low11(i,:),'k')
plot(hall_up11(i,:),'k')
inBetween = [hall_low11(i,:), fliplr(hall_up11(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low22(i,:),'k')
plot(hall_up22(i,:),'k')
inBetween2 = [hall_low22(i,:), fliplr(hall_up22(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow  2-year German Govt. Yield','Interpreter','tex')
i=4;
subplot(2,3,i)
hold on
plot(hall_low11(i,:),'k')
plot(hall_up11(i,:),'k')
inBetween = [hall_low11(i,:), fliplr(hall_up11(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low22(i,:),'k')
plot(hall_up22(i,:),'k')
inBetween2 = [hall_low22(i,:), fliplr(hall_up22(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef_orth(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow  3-Year Exp. Inflation','Interpreter','tex')
i=5;
subplot(2,3,i)
hold on
plot(hall_low11(i,:),'k')
plot(hall_up11(i,:),'k')
inBetween = [hall_low11(i,:), fliplr(hall_up11(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low22(i,:), fliplr(hall_up22(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow IT-DEU Bond Spread','Interpreter','tex')
i=6;
subplot(2,3,i)
hold on
plot(hall_low1(i,:),'k')
plot(hall_up1(i,:),'k')
inBetween = [hall_low11(i,:), fliplr(hall_up11(i,:))];
fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
plot(hall_low2(i,:),'k')
plot(hall_up2(i,:),'k')
inBetween2 = [hall_low22(i,:), fliplr(hall_up22(i,:))];
fill([1:max, fliplr(1:max)], inBetween2, 'k','FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
plot(sMA_coef(i,1:max),'r')
yline(0,'k')
title('FG \rightarrow Corp. Bond Spread','Interpreter','tex')


%Comparing IRFs from raw and from orthogonalised proxy.

figure()
subplot(2,3,1)
hold on
plot(sMA_coef(1,1:max),'r')
plot(sMA_coef_orth(1,1:max),'k--')
yline(0,'k')
title('FG \rightarrow  ln(Ind. Prod)','Interpreter','tex')
hold off
i=2;
subplot(2,3,i)
hold on
plot(sMA_coef(i,1:max),'r')
plot(sMA_coef_orth(i,1:max),'k--')
yline(0,'k')
title('FG \rightarrow  ln(HICP)','Interpreter','tex')
i=3;
subplot(2,3,i)
hold on
plot(sMA_coef(i,1:max),'r')
plot(sMA_coef_orth(i,1:max),'k--')
yline(0,'k')
title('FG \rightarrow  2-year German Govt. Yield','Interpreter','tex')
i=4;
subplot(2,3,i)
hold on
plot(sMA_coef(i,1:max),'r')
plot(sMA_coef_orth(i,1:max),'k--')
yline(0,'k')
title('FG \rightarrow  3-Year Exp. Inflation','Interpreter','tex')
i=5;
subplot(2,3,i)
hold on
plot(sMA_coef(i,1:max),'r')
plot(sMA_coef_orth(i,1:max),'k--')
yline(0,'k')
title('FG \rightarrow IT-DEU Bond Spread','Interpreter','tex')
i=6;
subplot(2,3,i)
hold on
plot(sMA_coef(i,1:max),'r')
plot(sMA_coef_orth(i,1:max),'k--')
yline(0,'k')
title('FG \rightarrow Corp. Bond Spread','Interpreter','tex')
