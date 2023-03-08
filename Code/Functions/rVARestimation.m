function var_est = rVARestimation(y,spec)
%Adapted from the code provided by Dr. Trenkler for the 2020 MTSA class:
%Title: estimate_var.m
%Author: Carsten Trenkler
%Date:2020

%The estimator is:
% B = YZ'(ZZ')^-1

%Where Y = [Y1.....YT] so dimenstion (KxT)
%Z = [Z_0, ..., Z_{T-1}]. Escj Z_{i} is of dimension (pk+1x1), so Z is of
%dimension pk+1 x T. Thus B is of dimension KxKp+1


%first I need to generate these matrices given the data and the parameters
%K, p and T.
[TT,k] = size(y);  %take the length of the data along its row dimension

%p presamples are assumed to exists, making the effective time periods, T:

p = spec.p;

deter = spec.deter;

T = TT - p;
var_est.T = T; %how many time periods were used

Y = y((p+1):end,:);  %I remove the first p lags
Y = Y'; %make the dimensions consistent with Luhtkepohl

%Z is more complicated since its essentially a matrices of matrices,


ylagged = lagmatrix(y,[1:p])'; 
%this creates the lags of the variables, essentially
%the  first p obsevations gets removed. I take its transpose so that the
%dimensions conform with the above. 
%Notice as well that the p first observations are not removed as in the
%case of Y. 


%Then I take only the columns(lags) that do not contain NaNs:

Z = ylagged(:,(p+1):end);


spec.deter = deter;

if deter == 1
    Z = [ones(1,T);Z];
end

var_est.Z = Z; 
%the previous inserts a constant, no trend allowed, for now. 

%Each column of Z contains a lagged values of both variables
%Essentially the first column of Y, Y_1, which contains the values for both
%variables in the first time period will be 'regressed' against Z_0 which
%contains the p lagged values of Y_1, (which is why this lagged values are
%exlcuded) from Y. 

var_est.B = Y*Z'*(Z*Z')^(-1);   



%by far the most confusing part is the lagmatrix. taking the tranpose of
%the generated lagged matrix. It is confusing because it takes away the
%first values while keeping the last ones. That is our Z matrix is really
%Z=[Z_{T-1}.....Z0]. So long as Y is also [Y_T,.....,Y_0] this is fine. 

%Transposing it actially gets it in the correct form of little y being a
%column vector. 




%Residuals

var_est.U_res = Y - var_est.B*Z;

%Residuals variance covariance matrix. 
var_est.SigmaU = var_est.U_res*var_est.U_res'/(T-k*p-deter);

%Residuals correlation matrix
var_est.CorrelU = corrcov(var_est.SigmaU);

%The OLS estimator's Asymptotic Variance Covariance Matrix
var_est.SigmaB = kron(((1/T)*(Z*Z'))^(-1),var_est.SigmaU);

%Recall the diagonals have the variances for each estimate and that the T
%ratios are just like simple cross sectional OLS. Then, each estimate must
%be divided by the appropriate element in the Variance covariance matrix of
%the estimator. 


A=sqrt(diag((1/T)*var_est.SigmaB));
B=reshape(var_est.B ,[k*(p*k+1),1]);

var_est.Tstats = B./A;


%T ratios are in a column vector. [c1;c2;a11;a21;a12;a22....]



%Companion Form 
if deter ==1
    As = var_est.B(:,2:end);
    var_est.c = var_est.B(:,1);
else
    As = var_est.B;
end

dummy = [eye(k*(p-1)),zeros(k*(p-1),k)];
lordA = [As;dummy];

var_est.normallordA = lordA; %is only used for bootstrap replications. especialyl when there is lag augmentation. 




%Following Dolado and Lutkepohl (2007)
%basically, if lag augmentation is being done I can delete the last K
%columns of the estimated B and the only quantity to be recomputed are the
%standard errors of the estimates and the t stats.

%Section based on Kilian and Lutkepohl SVAR Chapter 2 and Toda and Yamoto
%1995. Even though we estimate k+1 lags the last lag is regarded as zeros.  


if spec.lagaugmentation == 1
   fprintf(['ATTENTION: LAG AUGEMENTATION IS BEING PERFORMED!\n',...
   'THIS REMOVES THE LAST K COLUMNS IN THE MARIX OF ESTIMATED PARAMETERS.\n']);

clear lordA
%Redefine z

% Z = Z(1:end-k,:); %delete last k rows 
% 
% var_est.Z = Z;

%The main change in the following is that we take the upper left hand side
%submatrix as part of the procedure outlined by Dolado and Lukt. 
%remove last k columns

var_est.B = var_est.B(:,[1:(end-k)]);  


%the residuals
% var_est.U_res = Y - var_est.B*Z;

%Residuals variance covariance matrix. 
% var_est.SigmaU = var_est.U_res*var_est.U_res'/(T-k*p-deter); %remains as p?

%All statistics are calculated as usual but they are not reported for the
%last k*k paramaters. 


%The OLS estimator's Asymptotic Variance Covariance Matrix
% var_est.SigmaB = kron(((1/T)*(Z*Z'))^(-1),var_est.SigmaU);



%companion form, computed above but now last K matrices are removed
As = As(:,1:end-k);
%As = [As, zeros(k,k)];

%dummy = [eye(k*(p-1)),zeros(k*(p-1),k)];
dummy = [eye(k*(p-2)),zeros(k*(p-2),k)];
lordA = [As;dummy];

end



%stability check. 
eigenvalues = eig(lordA);

var_est.eigenvalues = eigenvalues;
var_est.abseigenvalues = abs(eigenvalues);

if any(abs(eigenvalues) > 1)
   fprintf('\n WARNING! UNSTABLE VAR');
end



%MA COEFFICIENTS: 
var_est.lordA=lordA;

max= 50;
MA_coef = NaN(k,k*max); 

%J = [eye(k),zeros(k,k*(p-1))];
MA_coef(1:k,1:k) = eye(k,k);
for i=1:(max)
    MA_coef_h = lordA^(i);
    MA_coef(:,i*k+1:(i+1)*k) =MA_coef_h(1:k,1:k);
end

var_est.MA_coef = MA_coef;


%plot reduced form IRFs?
if spec.impR ==1
sz = k; 
      
        
for j=1:k %this determines which shock we are plotting 
figure(j)
for i=1:k  %this determines which variables response we are plotting
subplot(1,sz,i)
plot(MA_coef(i,(j:k:end)))
end
end


end




end