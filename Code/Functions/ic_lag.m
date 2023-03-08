function ic_obj=ic_lag(data,foptions)


%Title:iclag.m
%Author: Professor Dr. Carsten Trenkler. 
%Date:2020
%Availability: MTSA portal. 

%This code has been written in its entirety by Professor Dr. Carsten
%Trenkler for the class Multiple Time Series Analysis at the University of
%Mannheim. 

% Determines optimal lag order using ICs for VAR permitting linear trends
% Considered ICs: AIC, BIC and HQ
%
% Uses function var_estimate for estimating VAR     
%
% INPUT: 
%	data        (T x K) time series data
%   foptions    (1 x 1) structure  
%           .pmax
%           .DeterTerms
%
% Outputs: 
%	ic_obj        
%		.aicV    values of AIC for p=0,1, ... , pmax
%		.bicV    values of BIC for p=0,1, ... , pmax
%       .hqV     values of HQ for p=0,1, ... , pmax
%       .aicL    lag order estimated by AIC
%       .bicL    lag order estimated by BIC
%       .hqL     lag order estimated by HQ
%

pmax = foptions.pmax;

% Create vectors for storing values of IC
aicV = NaN(pmax+1,1);
bicV = NaN(pmax+1,1);
hqV = NaN(pmax+1,1);

% deterministic handed over to function estimate_var
foptionsVAR.DeterTerms = foptions.DeterTerms; 

% Loop: estimate lag order with ICs; p=0,1, ... , pmax
for lagp = 0:pmax
    
    % adjust starting period to guarantee same sample for all lag orders
    Yv = data(pmax-lagp+1:end,:); 
                                        
    % lag order handed over to function estimate_var                                    
    foptionsVAR.LagOrder = lagp;    
                                       
    % call function estimate_var to estimate VAR 
    % foptionsVAR: structure with fields containing input for function
    % var_obj: structure with fields containing output of function
    % function also determines ICs for given lag order
    
    var_obj=estimate_var(Yv,foptionsVAR);   
                                              
    % save values for IC
    aicV(lagp+1) = var_obj.AIC;
    bicV(lagp+1) = var_obj.BIC;
    hqV(lagp+1) = var_obj.HQ;

end

% Determine optimal lag orders = estimated lag orders
[v,MI] = min(aicV);
% Note: MI = row index with smallest value = estimated lag order + 1
aicL = MI-1;    

[v,MI] = min(bicV);
bicL = MI-1;    
    
[v,MI] = min(hqV);
hqL = MI-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Outputs collected in stucture IC_obj %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ic_obj.aicV = aicV;
ic_obj.bicV = bicV;
ic_obj.hqV = hqV;
ic_obj.aicL = aicL;
ic_obj.bicL = bicL;
ic_obj.hqL = hqL;
