function var_obj=estimate_var(data,foptions)

%Code Written by Professor Dr. Carsten Trenkler for the class Multiple Time
%Series Analysis at Mannheim University. 

%Title: estimate_var.m
%Author: Dr. Carsten Trenkler
%Date:2020
%Availability: MTSA Ilias page. 

% OLS estimation of VAR permitting linear trend
%
%      Y = D + A X + U 
%
%
%
% INPUT: 
%	data        (T x K) time series data
%   foptions    (1 x 1) structure  
%           .LagOrder
%           .DeterTerms
%
% Outputs: 
%	var_obj       
%          .Y            Y = [y_1, y_2, ... y_T]: (K x T); T: actual sample size
%          .Z            regressor matrix [1 trend y_(t-1) y_(t-2) ...
%                        y_(t-p)]: ((Kp+2) x T)
%          .B_hat        estimated parameter matrix: [nu delta A_1 A_2 ...
%                        A_p]: (K x (Kp+2)); delta: trend coefficient vector
%          .U_hat        residual matrix: (K x T)
%          .SigmaU_hat   (OLS) residual variance matrix (degree of freedom adjustment)
%          .SigmaU_tilde (ML) residual variance matrix
%          .RU_hat       (OLS) residual correlation matrix
%           Sigma_B_hat  Estimator of asymptotic variance matrix of B_hat
%          .SE_hat       matrix of standard errors for B_hat, same
%                        structure as B_hat
%          .t_ratiosM    matrix of t-rations for B_hat, same structure as B_hat
%          .AIC          value for AIC for estimated model
%          .BIC          value for BIC for estimated model
%          .HQ           value for HQ for estimated model
%
%   Note: if no linear trend specified, then relevant matrices have reduced
%   dimension, the same applies if no deterministic terms are included in
%   VAR

%------------------------------------------------------------------
% Some checks

[Tf,K]=size(data); 
if K>=Tf 
    error('data has to be of dimension (T x K)'); 
end

y_raw=data'; 

p=foptions.LagOrder; 
deter = foptions.DeterTerms;

if p == 0 && deter == 0
    error('include at least one lag or a deterministic component ');
end

%------------------------------------------------------------------
% Create regression objects (follows Lütkepohl (2005, Sect. 3.2))

T = Tf - p;                 % sample size
Y=y_raw(:,p+1:end);         % delete p initial values; dimension: K x T

Z = NaN(K*p+deter,T);       % allocation of regressor matrix

if p > 0                    % insertion of lags into Z                
    Ylags=lagmatrix(y_raw',1:p)';
    Z(deter+1:end,:) = Ylags(:,p+1:end);
end

if deter == 1               % insertion of determinstic terms into Z 
    Z(1,:) = ones(1,T);
elseif deter == 2
    Z(1:2,:) = [ones(1,T);(1:1:T)];
end

%------------------------------------------------------------------
% OLS estimation results

B_hat = Y*Z'/(Z*Z');        % OLS estimator as on slide 5 of Part 4

U_hat = Y - B_hat*Z;        % Residual matrix
SigmaU_hat = U_hat*U_hat'/(T-K*p-deter); % Residual (OLS) variance matrix

SigmaU_tilde = U_hat*U_hat'/T; % Residual (ML) variance matrix
% Residual correlation matrix
RU_hat = corrcov(SigmaU_hat);
% explicit calculation of residual correlation matrix:
% (diag(sqrt(diag(SigmaU_hat)))\SigmaU_hat)/diag(sqrt(diag(SigmaU_hat)))

% Variance matrix of OLS estimator 
Sigma_B_hat = kron(inv((Z*Z'/T)),SigmaU_hat); % as on slide 9 of Part 4

% Matrix of standard errors of OLS estimator; arranged as B_hat
SE_hat = reshape(sqrt(diag(Sigma_B_hat)/T),K,K*p+1);

% Matrix of t-ratios
t_ratiosM = B_hat./SE_hat;

% Infomation Criteria  (as in Lütkepohl (2005, Sect. 4.3) and
% slides 2 and 3 of Part 5); 
AIC = log(det(SigmaU_tilde)) + 2*p*K^2/T; 
HQ = log(det(SigmaU_tilde)) + 2*log(log(T))*p*K^2/T; 
BIC = log(det(SigmaU_tilde)) + log(T)*p*K^2/T; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Outputs collected in stucture var_obj %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var_obj.Y = Y;
var_obj.Z = Z;
var_obj.B_hat = B_hat;
var_obj.U_hat = U_hat;
var_obj.SigmaU_hat = SigmaU_hat;
var_obj.SigmaU_tilde = SigmaU_tilde;
var_obj.RU_hat = RU_hat;
var_obj.Sigma_B_hat = Sigma_B_hat;
var_obj.SE_hat = SE_hat;
var_obj.t_ratiosM = t_ratiosM;
var_obj.AIC = AIC;
var_obj.BIC = BIC;
var_obj.HQ = HQ;























