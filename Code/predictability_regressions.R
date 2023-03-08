#ANTICIPATION REGRESSIONS


standard<-c('data.table','sandwich', 'lmtest', 'stargazer','dynlm', 'texreg' ,'tsutils','xtable') #Define vector with your packages
lapply(standard, invisible(library), character.only=T) #apply library command to each element in standard


monthlyvars2 <-fread('monthlydata2.csv') 

start=15
monthlyvars2 = monthlyvars2[start:nrow(monthlyvars2),]
EUROSTOXX = monthlyvars2$EUROSTOXX;
VSTOXX = monthlyvars2$VSTOXX;
corp_spread=monthlyvars2$spr_nfc_bund_de
CISS = monthlyvars2$CISS
R02=monthlyvars2$R02
sFG_cw = monthlyvars2$SFG_CW

EUVars = fread('EU.csv');
EUVars = EUVars[start:nrow(EUVars),];

HICP = EUVars$HICP
IP = EUVars$IP
UR = EUVars$URATE
EX = EUVars$EXCH

start=58
anticipation = fread('anticipation_data.csv')
anticipation = anticipation[start:nrow(anticipation),]




euribor3 = anticipation$EURIBOR3M;
spread_ITDEU = anticipation$ITDEU_spread;
spread_SPDEU = anticipation$SPDEU_spread;
nowcast = anticipation$Index;
EONIA = anticipation$EONIA_RATE;
manu_conf = anticipation$MC;
exp_inf_3 = anticipation$x3YExpInf;
exp_inf_1 = anticipation$x1YExpInf;


diff(EONIA) #doesnt show NAN
lagmatrix(EONIA,1) #SHOWS NA


fm.1=  lm(sFG_cw[2:length(sFG_cw)]~ lagmatrix(diff(euribor3),1))
g = summary(fm.1)
R1 = g$r.squared
F1 = g$fstatistic[[1]]



fm.3=  lm(sFG_cw[2:length(sFG_cw)]~ lagmatrix(diff(EONIA),1))
g = summary(fm.3)
R3 = g$r.squared
F3 = g$fstatistic[[1]]

fm.4=  lm(sFG_cw[2:length(sFG_cw)]~ lagmatrix(diff(manu_conf),1))
g = summary(fm.4)
R4 = g$r.squared
F4 = g$fstatistic[[1]]

fm.5=  lm(sFG_cw[2:length(sFG_cw)]~ lagmatrix(diff(exp_inf_3 ),1))
g = summary(fm.5)
R5 = g$r.squared
F5 = g$fstatistic[[1]]

fm.6=  lm(sFG_cw[2:length(sFG_cw)]~ lagmatrix(diff(exp_inf_1),1))
g = summary(fm.6)
R6 = g$r.squared
F6 = g$fstatistic[[1]]

fm.7=  lm(sFG_cw[1:length(sFG_cw)]~ lagmatrix((spread_ITDEU),1))
g = summary(fm.7)
R7 = g$r.squared
F7 = g$fstatistic[[1]]

fm.8=  lm(sFG_cw[1:length(sFG_cw)]~ lagmatrix((spread_SPDEU),1))
g = summary(fm.8)
R8 = g$r.squared
F8 = g$fstatistic[[1]]

fm.9=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(EUROSTOXX),1))
g = summary(fm.9)
R9 = g$r.squared
F9 = g$fstatistic[[1]]

fm.10=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(VSTOXX),1))
g = summary(fm.10)
R10 = g$r.squared
F10 = g$fstatistic[[1]]


fm.11=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(HICP),1))
g = summary(fm.11)
R11 = g$r.squared
F11 = g$fstatistic[[1]]

fm.12=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(UR),1))
g = summary(fm.12)
R12 = g$r.squared
F12 = g$fstatistic[[1]]



fm.13=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(IP),1))
g = summary(fm.13)
R13 = g$r.squared
F13 = g$fstatistic[[1]]

fm.14=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(corp_spread),1))
g = summary(fm.14)
R14 = g$r.squared
F14 = g$fstatistic[[1]]

fm.15=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(R02),1))
g = summary(fm.15)
R15 = g$r.squared
F15 = g$fstatistic[[1]]


fm.16=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(CISS),1))
g = summary(fm.16)
R16 = g$r.squared
F16 = g$fstatistic[[1]]


fm.17=  lm(sFG_cw[2:length(sFG_cw)]~lagmatrix(diff(EX),1))
g = summary(fm.17)
R17 = g$r.squared
F17 = g$fstatistic[[1]]

texreg(list(fm.1, fm.3,fm.4,fm.5,fm.6,fm.7,fm.8, fm.9, fm.10, fm.11, fm.12, fm.13, fm.14, fm.15, fm.16, fm.17),omit.coef="group",  digits = 4,include.rsquared=TRUE , include.fstatistic=TRUE)

variables = c(variable.names(fm.1)[2],variable.names(fm.3)[2],variable.names(fm.4)[2],variable.names(fm.5)[2],variable.names(fm.6)[2],variable.names(fm.7)[2],variable.names(fm.8)[2],variable.names(fm.9)[2],variable.names(fm.10)[2],variable.names(fm.11)[2],variable.names(fm.12)[2],variable.names(fm.13)[2],variable.names(fm.14)[2],variable.names(fm.15)[2],variable.names(fm.16)[2],variable.names(fm.17)[2])
Rstats = round(c(R1,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13, R14,R15,R16,R17),digits = 5)
Fstats = round(c(F1,F3,F4,F5,F5,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17), digits=5)

t = matrix(c(variables,Rstats,Fstats), nrow=16)
print(xtable(t), include.rownames=FALSE)