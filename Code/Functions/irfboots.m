%Moving Block Bootstrap for Proxy SVAR
%Some parts are adapted from Dr. Trenklers bootstrapping code for his MTSA
%2020 class. The centering of the residuals and the proxy variable is due
%to Cesa Biachi code for the paper Monetary Policy Transmission in 
%the United Kingdom: A High Frequency Identification Approach who adapts 
%it from the work done  Kurt Lunsford and Carl Jentsch work. 



function irf_proxysvar = irfboots(y,proxy,spec)

rng(4)


%specifications needed to call function:

p = spec.p; %number of lags including augmentation
max = spec.max; %max time periods aheads
bs = spec.bs;   %number of bootstrap replications
level1 = spec.level1;  %significance level 
level2 = spec.level2;
deter = spec.deter;   %are constant included?
l = spec.length;      %length of blocks
lagaugm = spec.lagaugmentation;   %lag augmentation 
pos = spec.pos;
k = size(y,2);
irf = spec.IRF; %plot IRFs?

sPhi = zeros(k,k*(max),bs);

T = size(y,1) - p;
N = ceil(T/l);


%Start the bootstrapping
for q = 1:bs
    
prox= 	proxy'; %set the proxy in the correct dimension    
    

%SPECIFICATIONS FOR REDUCED FORM VAR, THESE ARE TAKEN FROM THE
%SPECIFICATION ABOVE. 
specVAR.p =p;
specVAR.deter=1;
specVAR.impR =0;                  
specVAR.lagaugmentation=lagaugm;   

JakeVAR = rVARestimation(y, specVAR);


%Take elements needed from the reduced form estimation: the residual, the
%companion form matrix and the vector of constants. 

res = JakeVAR.U_res; 
lordA = JakeVAR.normallordA;
c = JakeVAR.c;


%Step 1: ''Collect K*l blocks U for i = 1...T-L+1 and  r*L blocks M. ''

block_res =NaN(k,l,T-l+1); %T-L+1 blocks of equal length 
for i = 1:T-l+1
block_res(:,:,i) = res(:,i:l+i-1);
end

block_proxy =NaN(1,l,T-l+1); %T-L+1 blocks of equal length 
for i = 1:T-l+1
block_proxy(:,:,i) = prox(1,i:l+i-1);
end
irf_proxysvar.block_proxy = block_proxy;

%CENTERING ADAPTED FROM CESA BIANCHIS CODE. 
%These matrices will be used to center the bootrapped quantities later on.
%for the residuals:
centering = zeros(k,l);
for j = 1:l
centering(:,j) = mean(res(:,j:T-l+j),2);      %takes the mean of each residual series (mean of each row).
end
centering = repmat(centering,[1,N]);   %copy it N taimes    
centering = centering(:,1:T);         %Take first T 


%for the proxy
%note that the mean is taken only for non-zero entries. 
Mcentering = zeros(1,l);
for j = 1:l
                subM = prox(:,j:T-l+j);
                Mcentering(:,j) = [mean(subM((subM(:,1) ~= 0),1),2)];   %NOTICE CENSORING!
end

Mcentering = repmat(Mcentering,[1,N]);
Mcentering = Mcentering(:,1:T);


%Step 2: Independently draw N intergers with replacements from the set
%{1,...,T-l+1}. Putting equal probability on all elements."


r = randsample(T-l+1,N,true);

%Step 3: Collect blocks and drop the last Nl-T elements to produce the
%bootstrapping quantities' 
    U = NaN(k,l,size(r,1));
    M = NaN(1,l,size(r,1));
for i = 1:size(r,1)
    U(:,:,i) = block_res(:,:,r(i));     
    M(:,:,i) = block_proxy(:,:,r(i));
end
U = reshape(U, k,[]) ;     %the reshape concatenates the blocks  
M = reshape(M, 1, []);

U = U(:,1:(end-(N*l-T)));
M = M(:,1:(end-(N*l-T)));


%Step 4: center bootrapped quantities conditional on the data
 
u = U - centering;      
irf_proxysvar.u =u;

m = NaN(1,T);
for i=1:size(M,2)
if  M(:,i) ~= 0
    m(:,i) = M(:,i) - Mcentering(:,i);
else
    m(:,i) = 0;
end
end




%Step 5: Set initial conditions along with reduced VAR parameter matrices
%to produce bootrapped observations of y_t.

%Recursively producing bootstrap samples. Section Based on Carsten's
%bootstrap code for MTSA. 
%Store the bootrap samples. Notice the companion form structure. 
Ybs = zeros(k*p,T+1);
%T+1 since we generate T bootrap samples and the first column is reserved
%for the pre samples.
pre_samples = y(1:p,:)'; %Carsten sets these to 0. 
%pre_samples = zeros(size(y(1:p,:)'));



pre_samples = reshape(pre_samples, [],1);
Ybs(:,1) = pre_samples;


if p == 1                  % generate boostrap series
    for i = 2:T+1
        Ybs(:,i) = c + lordA*Ybs(:,i-1) + u(:,i-1);
    end
else
    for i = 2:T+1
        cc = [c;zeros(k*(p-1),1)];
            Ybs(:,i) = cc + lordA*Ybs(:,i-1) + [u(:,i-1);zeros(k*(p-1),1)];
    end
end
 

% Bootstrap time series with p zero pre-sample values in regular form: 
% dimension KxT
Y_bs = [reshape(pre_samples, k,p),Ybs(1:k,2:end)]; %i have to take the pre sample ones as well otherwise dimension inconsistency



%Step 6: Call the proxy svar code to estimate B1.



specSVAR.p=p;
specSVAR.deter=deter;
specSVAR.lagaugmentation = lagaugm;
specSVAR.pos=pos;
woop =proxy4(Y_bs',m',specSVAR);
% woop = proxysvar3(Y_bs',m',specSVAR);



irf_proxysvar.bootY= Y_bs';
irf_proxysvar.bootm = m';


B1(:,:,q) = woop.B1;  %this is equivalent to making it positive again????. 
irf_proxysvar.woopMA(:,:,q) = woop.MA_coef;
irf_proxysvar.B1BS=B1;



%Step 7: Call the reduced form VAR to compute MA parameter matrices based 
%on bootrapped sample.  



reduced_bs= rVARestimation(Y_bs',specVAR);

%The only quantity of interests are the MA matrices. 
MA_bs = reduced_bs.MA_coef;
irf_proxysvar.Phi(:,:,q) = MA_bs;

%Construct IRF based on MA representation obtained from the reduced form
%and the B1 column vector obtained from the proxy code. 

for i=1:k:k*max
    sPhi(:,i,q) = irf_proxysvar.Phi(:,(i:i+k-1),q)*B1(:,:,q);  
end

%Once all this is done the bootstrap is concluded. 
end

%saving it for output. 
irf_proxysvar.sPhi(:,:,:) = sPhi; 



%now we need to sort it (since we want it like an EDF)
sPhi_boot = sort(sPhi,3);%we sort along the third dimension.


low1 = ceil((1-level1)*(bs+1)/2); %lower bound: anything above this one is taken out
up1 = bs-low1+1;                  %upper bound: anything below this is to be taken out


%For second bounds
low2 = ceil((1-level2)*(bs+1)/2); 
up2 = bs-low2+1;







%%%%%%POINT ESTIMATE%%%%%%%%%%%%%

%Utilises the same specification as above to call to estimate B1 on the
%original sample. 
specSVAR.p=p;
specSVAR.deter=deter;
specSVAR.lagaugmentation = lagaugm;
specSVAR.pos=pos;
point =proxy4(y,proxy(p+1:end),specSVAR);
% point =proxysvar3(y,proxy(p+1:end),specSVAR);
%Store B1
B1 = point.B1;
irf_proxysvar.B1 =B1;


%Call reduced form and estimate MA parameter matrices:
reducedpoint = rVARestimation(y,specVAR);

%Store MA coefficients
MA_point = reducedpoint.MA_coef;





%Compute structural impulse responses for the point estimate. 

sMA_coef = NaN(k,k*max);
for i=1:k:k*max
    sMA_coef(:,i) = MA_point(:,i:i+k-1)*B1;
end


%Once all these quantities are obtained I can compute Hall intervals.

%%%%%%%%%%%%%%%%%%  Hall %%%%%%%%%%%%%%%%%%%%%%%%%%%%
hall_low1 = zeros(k,k*(max));
hall_low1(:,:) = 2*sMA_coef -  sPhi_boot(:,1:k*max,low1);

hall_up1 = zeros(k,k*(max));
hall_up1(:,:) = 2*sMA_coef -  sPhi_boot(:,1:k*max,up1);





hall_low2 = zeros(k,k*(max));
hall_low2(:,:) = 2*sMA_coef -  sPhi_boot(:,1:k*max,low2);

hall_up2 = zeros(k,k*(max));
hall_up2(:,:) = 2*sMA_coef -  sPhi_boot(:,1:k*max,up2);

%%%%%%%%%%%%%%%% Saving output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


hall_low1 = rmmissing(hall_low1,2);
hall_up1 = rmmissing(hall_up1,2);
hall_low2 = rmmissing(hall_low2,2);
hall_up2 = rmmissing(hall_up2,2);
sMA_coef =rmmissing(sMA_coef,2);



irf_proxysvar.sMA_coef = sMA_coef;
irf_proxysvar.hall_low1 = hall_low1;
irf_proxysvar.hall_up1 = hall_up1;
irf_proxysvar.hall_low2 = hall_low2;
irf_proxysvar.hall_up2 = hall_up2;

%%%%%%%%%%%%%%%%%% IRF plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if irf==1
sz=k;
 for i=1:k  %this determines which variables response we are plotting
 subplot(1,sz,i)
 hold on
 plot(hall_low1(i,:),'k')
 plot(hall_up1(i,:),'k')
 inBetween = [hall_low1(i,:), fliplr(hall_up1(i,:))];
 fill([1:max, fliplr(1:max)], inBetween, 'k','FaceColor',[0.7 0.7 0.7],'EdgeColor','none');
 plot(sMA_coef(i,:),'r')
 end
end

end
