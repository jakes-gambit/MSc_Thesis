%%%Proxy SVAR v4

% Takes the following inputs:
% y is the data for the VAR 
% x is the proxy variables
%spec: 
%     .deter: include deterministic?
%     .p = lag order
%     .lagaugmentation , are we doing lag augmentation

%In addition some of these specification are passed onto the reduced form. 

function proxy4_est = proxy4(y,x,spec)

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
proxy4_est.MA_coef = MA_coef;
%From the reduced form I get the residuals and the MA matrices.

U = rvar.U_res;   %the reduced form residuals






pos= spec.pos; 

alpha = -(1/T)*(U(pos,:)*x);






B1_V1 = (1/T)*(U(:,:)*x);

B1 = B1_V1/alpha;

proxy4_est.B1=B1;
 end

