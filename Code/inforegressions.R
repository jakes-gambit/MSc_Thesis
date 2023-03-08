
standard<-c('data.table','sandwich', 'lmtest', 'stargazer','dynlm', 'texreg','readxl') #Define vector with your packages
lapply(standard, invisible(library), character.only=T) #apply library command to each element in standard




###The first set of regressions will test whether FG surprises are associated with revisions on macroeconomic factors. 
#NOWCAST
nowcastdata = fread('news_nowcast.csv') 
start = 15
nowcastdata = nowcastdata[start:nrow(nowcastdata),];


effectivesur = ts(nowcastdata$effectivesur);
HICP_revision = ts(nowcastdata$HICP_revision);
GDP_revision = ts(nowcastdata$GDP_revision)


fm.1 = lm(HICP_revision~effectivesur)
fm.2 = lm(GDP_revision~effectivesur)


l1 = coeftest(fm.1 , df = Inf, vcov = NeweyWest)
se1 <- l1[, 2]
pval1 <- l1[, 4]

l2 = coeftest(fm.2 , df = Inf, vcov = NeweyWest)
se2 <- l2[, 2]
pval2 <- l2[, 4]

texreg(list(fm.1, fm.2), override.se = list(se1, se2), override.pvalues = list(pval1, pval2), include.fstatistic=TRUE, digits=4)


#FORECAST


forecastdata = fread('news_forecasts.csv') 
start = 15
forecastdata = forecastdata[start:nrow(forecastdata),];

effectivesur = ts(forecastdata$effectivesur);
HICP_revision = ts(forecastdata$HICP_revision);
GDP_revision = ts(forecastdata$GDP_revision);


fm.3 = lm(HICP_revision~effectivesur)
fm.4 = lm(GDP_revision~effectivesur)


l3 = coeftest(fm.3 , df = Inf, vcov = NeweyWest)
se3 <- l3[, 2]
pval3 <- l3[, 4]

l4 = coeftest(fm.4 , df = Inf, vcov = NeweyWest)
se4 <- l4[, 2]
pval4 <- l4[, 4]

texreg(list(fm.3, fm.4), override.se = list(se3, se4), override.pvalues = list(pval3, pval4), include.fstatistic=TRUE, digits=4)




texreg(list(fm.1, fm.2,fm.3, fm.4), override.se = list(se1, se2,se3, se4), override.pvalues = list(pval1, pval2,pval3, pval4), include.fstatistic=TRUE, digits=4)


#The second set of regressions will test whewther proxying fro news releases solves the problematic revisions. 
#For the forecast

news = fread('news_forecasts.csv') 
start = 15
news = news[start:nrow(news),];


fm.5 = lm(HICP_revision~ effectivesur + EUROSTOXX,data=news)
summary(fm.5)

l5 = coeftest(fm.5, df = Inf, vcov = NeweyWest)
se5 <- l5[, 2]
pval5 <- l5[, 4]




fm.6 = lm(GDP_revision~effectivesur + EUROSTOXX, data=news)
summary(fm.6)

l6 = coeftest(fm.6, df = Inf, vcov = NeweyWest)
se6 <- l6[, 2]
pval6 <- l6[, 4]

texreg(list(fm.5, fm.6), override.se = list(se5, se6), override.pvalues = list(pval5, pval6), include.fstatistic=TRUE, digits=4)



#For the Nowcast:

news = fread('news_nowcast.csv') 
start = 15
news = news[start:nrow(news),];


fm.7 = lm(HICP_revision~ effectivesur + EUROSTOXX,data=news)
summary(fm.7)

l7 = coeftest(fm.7, df = Inf, vcov = NeweyWest)
se7 <- l7[, 2]
pval7 <- l7[, 4]




fm.8 = lm(GDP_revision~effectivesur + EUROSTOXX, data=news)
summary(fm.8)

l8 = coeftest(fm.8, df = Inf, vcov = NeweyWest)
se8 <- l8[, 2]
pval8 <- l8[, 4]

texreg(list(fm.7, fm.8), override.se = list(se7, se8), override.pvalues = list(pval7, pval8), include.fstatistic=TRUE, digits=4)




#combining the regressions output:
texreg(list(fm.7, fm.8,fm.5, fm.6), override.se = list(se7, se8,se5, se6), override.pvalues = list(pval7, pval8,pval5, pval6), include.fstatistic=TRUE, digits=4)











####
#The third set of regressions will assess whether the impact of high frequency stock movements 
#as in the monetary database and the fg factor on HICP revisions and whether it could proxy for news.
#Starting with forecasts:
hf_forecasts = fread('HFI_forecasts.csv')
start = 3
hf_forecasts = hf_forecasts[start:nrow(hf_forecasts),];

fm.9 = lm(HICP_revision~ EffectiveSurprise + STOXXMovements , data = hf_forecasts)
texreg(fm.9, digits = 4)

l9 = coeftest(fm.9, df = Inf, vcov = NeweyWest)
se9 <- l9[, 2]
pval9 <- l9[, 4]

fm.10 = lm(GDP_revision~ EffectiveSurprise + STOXXMovements , data = hf_forecasts)
texreg(fm.10, digits = 4)

l10 = coeftest(fm.10, df = Inf, vcov = NeweyWest)
se10 <- l10[, 2]
pval10 <- l10[, 4]

texreg(list(fm.9, fm.10), override.se = list(se9, se10), override.pvalues = list(pval9, pval10), include.fstatistic=TRUE, digits=4)


#now with nocasts:
hf_nowcasts = fread('HFI_nowcasts.csv')
start = 3
hf_nowcasts = hf_nowcasts[start:nrow(hf_nowcasts),];

fm.11 = lm(HICP_revision~ EffectiveSurprise + STOXXMovements , data = hf_nowcasts)
texreg(fm.11, digits = 4)

l11 = coeftest(fm.11, df = Inf, vcov = NeweyWest)
se11 <- l11[, 2]
pval11 <- l11[, 4]

fm.12 = lm(GDP_revision~ EffectiveSurprise + STOXXMovements, data = hf_nowcasts)
texreg(fm.12, digits = 4)

l12 = coeftest(fm.12, df = Inf, vcov = NeweyWest)
se12 <- l12[, 2]
pval12 <- l12[, 4]

texreg(list(fm.11, fm.12), override.se = list(se11, se12), override.pvalues = list(pval11, pval12), include.fstatistic=TRUE, digits=4)


#combining regression outputs. 
texreg(list(fm.11, fm.12, fm.9, fm.10), override.se = list(se11, se12, se9,se10), override.pvalues = list(pval11, pval12,pval9,pval10), include.fstatistic=TRUE, digits=4)



