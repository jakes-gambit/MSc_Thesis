%Testing for the Number of Factors. Follows GSS.
% The functions for the rank testing has been provided by Gurkaynak, R.
% S., Sack, B. P., & Swanson. For further details are dicussed within the
% specific functions. 

acr = readtable('ACR.csv');
%From 2002 to 2019. 
acr = acr(35:224,:);
acr1 = table2array(acr(:,2:8)); 


%Taking variables for testing. 
x = acr1;

%I now test for rank order using the statistic proposed byh Cragg and
%Donald in 1997 and the code provided by the GSS authors. 
ranktest(x,3,0)

%for the entire sample there appears to be all 3 factors.


%pre financial crises: Beggining to Aug 2008
x = acr1;
x = x(1:75,:);
ranktest(x,3,0)
%pre financial crises there appears to be 2 factors. 

%pre-QE, prior to December 2013
x = acr1;
x = x(1:138,:);
ranktest(x,3,0)


