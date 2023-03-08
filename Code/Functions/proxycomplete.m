%Final Proxy SVAR code:
%Estimator from Stock and Watson (2012), F-test from Lunsford (2016)



% Takes the following inputs:
% y is the data for the VAR 
% x is the proxy variables
%spec: 
%     .deter: include deterministic?
%     .p = lag order
%     .lagaugmentation , are we doing lag augmentation
%     .IRF, plot impulse responses? NO bootstrap is included. 
%     .c threshold value as in Lunsford. For the F test. Values are in page
%     14. 
%     .shocks include shocks history? 

%In addition some of these specification are passed onto the reduced form. 

%The series dates is required for plotting the shock series. 

function proxysvar_est = proxycomplete(y,x,spec)

[TT,k] = size(y);
p=spec.p;
T = TT - p;



deter = spec.deter;
lagaugm = spec.lagaugmentation;



%summon the reduced var code and pass on relevant specifications


specrVAR.p =spec.p;
specrVAR.deter=deter;
specrVAR.impR =0;      %always set to 0, not interested in the reduced irf. 
specrVAR.lagaugmentation=lagaugm;



rvar = rVARestimation(y,specrVAR);
MA_coef = rvar.MA_coef; 
proxysvar_est.MA_coef = MA_coef;
%From the reduced form I get the residuals and the MA matrices.

U = rvar.U_res;   %the reduced form residuals



pos= spec.pos;


size(x);
size(U(pos,:));

%take the proxies for the correct time frame:

x = x(spec.p+1:end);

alpha = (1/T)*(U(pos,:)*x);
proxysvar_est.cov = alpha;


B1_V1 = (1/T)*(U(:,:)*x);
proxysvar_est.B1_v1 =B1_V1;

B1 = B1_V1/alpha;

proxysvar_est.B1=B1;



%Shock series (up to sign) fllowing Olea, Stock and Watson (2018)
if spec.shocks==1
lambda = ((1/T)*(U(:,:)*x));
Sigma = (1/T)*(U*U'); %covariance matrix of reduced form innovations

den = lambda'*Sigma^(-1)*lambda;

proxysvar_est.shocks = (lambda'*Sigma^(-1)*U)/den;
end


%Lunsford F-test
%To be consistent with Lunsford Notation:
Z=x; 
Z = reshape(Z,[1,T]);

pi = ((1/T)*(U*U'))^(-1)*((1/T)*(U*Z')); %Regression coefficients of instrument on innovations. 

F = ((T-k)/k)*((Z*Z'-(Z'-U'*pi)'*(Z'-U'*pi))/((Z'-U'*pi)'*(Z'-U'*pi)));  
nF = k*F;

%compute the corresponding Pr(x<nF)
c = spec.c;
df = k;
p1 = ncx2cdf(nF,c,df);

p = 1- p1;

proxysvar_est.p = p;


if p < 0.05
   fprintf('\n Woop Woop! Strong Proxy');
end




end
