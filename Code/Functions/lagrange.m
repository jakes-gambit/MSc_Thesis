
function lagrange = lagrange(h, res, z,p)

%Lagrange multiplier test for residual autocorrelation following
%Luhtekpohl and Kilian page 54 and Luhtkepohl 2005 book page 171. 

%Firstly, briefly recall some dimensions. B is Kx(Kp+1), Z is (Kp+1)xT, U
%is KxT. 

T = size(res, 2);
K = size(res,1);


eyeh = eye(h);


lordF = zeros(T,T*h);
for i =1:h
    Fi = zeros(T,T);
    Fi(1+i:end, 1:end-i) = eye(T-i,T-i);
    lordF(:,(i-1)*T+1:T*i) = Fi;
end


uf = kron(eyeh,res)*lordF';

%D = (res*uf')*(uf*uf' - uf*z'*((z*z')^(-1))*z*uf')^(-1)

%D must be of dimension K*kh

bigA = [res*z',res*uf']*([z*z', z*uf';uf*z', uf*uf']^(-1));

B = bigA(:,1:K*p+1);
D = bigA(:,K*p+2:end);

%Auxilliary regression residuals
auxi_res = res - B*z - D*uf; 


%Variance covariance matrices of original residuals and the auxiliary
%residuals. 
SigmaU = res*res'/(T);
SigmaU_aux = auxi_res*auxi_res'/T;
D = reshape(D,[],1);

%Test statistic
Q = (D)'*(kron(uf*uf' - uf*z'*((z*z')^(-1))*z*uf', SigmaU^(-1)))*(D);
pval = chi2cdf(Q ,h*K^2,'upper');


%F rao alternative:

s = (((K^4*h^2)-4)/(K^2+(K^2*h^2)-5))^(0.5);
N =   T - K*p -1 -K*h - 0.5*(K-K*h+1);
scale = (N*s-(0.5*((K^2)*h))+1)/K^2*h;

F = ((det(SigmaU)/det(SigmaU_aux))^(1/s) - 1)*scale;
pval2 = fcdf(F, h*K^2, N*s-0.5*(K^2*h)+1,'upper');

%Output.

lagrange.lordF = lordF;
lagrange.Q = Q; 
lagrange.pval1 = pval;
lagrange.Frao=F;
lagrange.pval2= pval2;


end

