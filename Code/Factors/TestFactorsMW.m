%Testing for the Number of Factors. Follows GSS.

%Factor Model 


amw = readtable('Alta.xlsx','Sheet','Monetary Event Window'); %name as per Altavilla Press Conference
dates_alta = datetime(amw.date,'Format','dd-MM-yyyy');


%Press Release Rates
ois1m_mw = amw.OIS_1M;
ois3m_mw = amw.OIS_3M;
ois6m_mw = amw.OIS_6M;
ois1y_mw = amw.OIS_1Y;
deu2y_mw = amw.DE2Y(1:187);
deu5y_mw = amw.DE5Y(1:187);
deu10y_mw = amw.DE10Y(1:187);


%recent addition, I use only deutsch rates pre Aug2011 and afterwrds the
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


%I assign the variable names again

%03 of Jan 2002 to end of 2019 period
ois1m_mw = amw.OIS_1M;
ois3m_mw = amw.OIS_3M;
ois6m_mw = amw.OIS_6M;
ois1y_mw = amw.OIS_1Y;
ois2y_mw = amw.OIS_2Y;
ois5y_mw = amw.OIS_5Y;
ois10y_mw = amw.OIS_10Y;



x = [ois1m_mw, ois3m_mw, ois6m_mw, ois1y_mw, ois2y_mw, ois5y_mw, ois10y_mw];


%I now test for rank order using the statistic proposed byh Cragg and
%Donald in 1997 and the code provided by the GSS authors. 
ranktest(x,3,0)

%for the entire sample there appears to be all 3 factors.


%pre financial crises: Beggining to Aug 2008
x = [ois1m_mw, ois3m_mw, ois6m_mw, ois1y_mw, ois2y_mw, ois5y_mw, ois10y_mw];
x = x(1:80,:);
ranktest(x,3,0)
%pre financial crises there is weak evidence for 2 factors but strong for only 1  



%pre-QE, prior to December 2013
x = [ois1m_mw, ois3m_mw, ois6m_mw, ois1y_mw, ois2y_mw, ois5y_mw, ois10y_mw];
x = x(1:145,:);
ranktest(x,3,0)




