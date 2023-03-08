%Testing for the Number of Factors. Follows GSS.

%Factor Model 


apr = readtable('Alta.xlsx','Sheet','Press Release Window'); %name as per Altavilla Press Conference
dates_alta = datetime(apr.date,'Format','dd-MM-yyyy');




dates_alta = datestr(dates_alta);

%Press Release Rates
ois1m_pr = apr.OIS_1M;
ois3m_pr = apr.OIS_3M;
ois6m_pr = apr.OIS_6M;
ois1y_pr = apr.OIS_1Y;
deu2y_pr = apr.DE2Y(1:187);
deu5y_pr = apr.DE5Y(1:187);
deu10y_pr = apr.DE10Y(1:187);

%recent addition, I use only deutsch rates pre Aug2011 and afterwrds the
%corresponfing OIS rates.

ois2y_pr = apr.OIS_2Y(188:end);
ois5y_pr = str2double(apr.OIS_5Y(188:end));
ois10y_pr = str2double(apr.OIS_10Y(188:end));


ois2y_pr = [deu2y_pr;ois2y_pr];
ois5y_pr = [deu5y_pr; ois5y_pr];
ois10y_pr = [deu10y_pr;ois10y_pr];



%I first delete all those dates for which there is no information
%available for at least one variable of interest. 

apr = table(dates_alta, ois1m_pr,ois3m_pr,ois6m_pr,ois1y_pr,ois2y_pr,ois5y_pr,ois10y_pr, 'VariableNames',{'Date','OIS_1M','OIS_3M','OIS_6M','OIS_1Y','OIS_2Y','OIS_5Y','OIS_10Y'}); 
apr= apr(~any(ismissing(apr),2),:);

apr = apr(72:end-4,:);
apr(83:84,:) = []; %removal of 08/10/2008 and 06/10/2008


%03 of Jan 2002 to end of 2019 period
ois1m_pr = apr.OIS_1M;
ois3m_pr = apr.OIS_3M;
ois6m_pr = apr.OIS_6M;
ois1y_pr = apr.OIS_1Y;
ois2y_pr = apr.OIS_2Y;
ois5y_pr = apr.OIS_5Y;
ois10y_pr = apr.OIS_10Y;


x = [ois1m_pr, ois3m_pr, ois6m_pr, ois1y_pr, ois2y_pr, ois5y_pr, ois10y_pr];


%I now test for rank order using the statistic proposed byh Cragg and
%Donald in 1997 and the code provided by the GSS authors. 
ranktest(x,3,0)

%for the entire sample there appears to be 2 factors.


%pre financial crises: Beggining to Aug 2008
x = [ois1m_pr, ois3m_pr, ois6m_pr, ois1y_pr, ois2y_pr, ois5y_pr, ois10y_pr];
x = x(1:80,:);
ranktest(x,3,0)
%evidence for one factor.



%pre-QE, prior to December 2013
x = [ois1m_pr, ois3m_pr, ois6m_pr, ois1y_pr, ois2y_pr, ois5y_pr, ois10y_pr];
x = x(1:143,:);
ranktest(x,3,0)
