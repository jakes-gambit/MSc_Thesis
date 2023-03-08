function [minval,mintheta] = ranktest(X,maxrank,minrank) 

%Title:ranktest.m
%Author: Eric Swanson
%Date:2004
%Availability: http://refet.bilkent.edu.tr/research.html

% Credits: this program was written by Eric Swanson in 2004 for the paper
%  "Do Actions Speak Louder than Words? The Response of Asset Prices to
%   Monetary Policy Actions and Statements" by Gurkaynak, Sack, and Swanson
%  in the Spring 2005 International Journal of Central Banking.
%   A copy of this program is available from the IJCB web site archive for
%  that paper.

% Test the number of factors in a matrix of data, X, using the rank test
%  described in Cragg and Donald (1997).
% X is a T x n matrix of data.  The columns of X will be normalized to
%  have unit variance, below (this is not necessary in theory, but helps
%  the code to find the minimum distance by standardizing the inputs as
%  as much as possible).
% maxrank is the maximum rank to test (default is 2)
% minrank is the minimum rank to test (default is 0)
%
% The function returns the minimum distance (minval) for the test of 
%  maxrank factors.
% Optionally, the function also returns the minimizing (maxrank+1) x n
%  matrix: mintheta.  
%  The first row of mintheta is the white noise standard
%  deviations in the closest factor model to the data; each row of
%  mintheta after the first gives the the factor loadings of the data on
%  each of the unobserved factors.  Note that these last k rows of mintheta
%  are only unique up to rotations of the unobserved factors.
%
% In order to calculate chi^2 critical values and p-values, this program
%  requires the Matlab Statistics Toolbox.  If you don't have this toolbox,
%  you can simply comment out those two lines of the code and look up
%  your critical values and p-values the old-fashioned way.
%

if (nargin<3); minrank=0; end ;
if (nargin<2); maxrank=2; end ;

X = X / diag(sqrt(diag(cov(X)))) ; % normalize columns of X to unit std dev
                                   % (unnecessary in theory, helps numerically)
[T,n] = size(X) ;
covX = cov(X) ;
meanX = mean(X) ;

vecsigma = covX(find(tril(ones(size(covX))))) ; % vech of cov matrix
bigN = length(vecsigma) ;

varvecsig = zeros(n,n,n,n) ; % calculate uncertainty about elements of cov(X)
for i1 = 1:n ;
for i2 = 1:n ;
for i3 = 1:n ;
for i4 = 1:n ;
  varvecsig(i1,i2,i3,i4) = ...
	sum( (X(:,i1) - meanX(i1)) .*(X(:,i2) - meanX(i2)) ...
		.*(X(:,i3) - meanX(i3)) .*(X(:,i4) - meanX(i4))) / T^2 ...
						- covX(i1,i2) *covX(i3,i4) /T ;
end ;
end ;
end ;
end ;

[index1,index2] = ind2sub(size(covX),find(tril(ones(size(covX))))) ;

for i=1:bigN ; % map elements of varvecsig array into matrix corresponding to
for j=1:bigN ; %  vech(covX)
  Vhat(i,j) = varvecsig(index1(i),index2(i),index1(j),index2(j)) ;
end ;
end ;


% Find minimum distance from data to all possible factor models of rank k.
%  We use four different initial guesses in order to increase the chances
%  that we have found a global min rather than just a local min.

for k = minrank:maxrank ;
  fprintf('\n\n-------------------------------------------------------------') ;
  fprintf('\n\nTesting null of rank %i  (data has %i columns):\n\n',k,n) ;
  df = (n-k)*(n-k+1)/2 - n ;
  if (df<1); fprintf('Rank test has no degrees of freedom for this test:\n') ;
    fprintf('A factor model with %i factors can fit the data perfectly\n',k) ;
  else ;

  theta0 = [ones(1,n)/3; zeros(k,n)] ; % initial guess 1
  [mintheta1,minval1] = fminunc('ranktestfun',theta0,...
  				  optimset('MaxIter',2000,'MaxFunEvals',90000),vecsigma,Vhat) ;

  theta0 = [ones(1,n)/3; ones(k,n)/(2*k)] ; % initial guess 2
  [mintheta2,minval2] = fminunc('ranktestfun',theta0,...
  				  optimset('MaxIter',2000,'MaxFunEvals',90000),vecsigma,Vhat) ;

  theta0 = [ones(1,n)/3; eye(k,n)/(2*k)] ; % initial guess 3
  [mintheta3,minval3] = fminunc('ranktestfun',theta0,...
  				  optimset('MaxIter',2000,'MaxFunEvals',90000),vecsigma,Vhat) ;

  theta0 = [ones(1,n)/3; fliplr(eye(k,n)/(2*k))] ; % initial guess 4
  [mintheta4,minval4] = fminunc('ranktestfun',theta0,...
				  optimset('MaxIter',2000,'MaxFunEvals',90000),vecsigma,Vhat) ;
%mintheta is the minimising matrix. It contains the white noise variances
%and the factor loadings (lambda). We are interested in the last K rows of
%mintheta as these are the lambda matrix.

%in the end only the minimum of the solutions given the guesses is taken.
  minval = min([minval1,minval2,minval3,minval4]) ;
  switch minval ;
    case minval1; mintheta=mintheta1;
    case minval2; mintheta=mintheta2;
    case minval3; mintheta=mintheta3;
    case minval4; mintheta=mintheta4;
  end ;

 % print out results:
  fprintf('white noise std devs:'); fprintf(' % 6.4f', abs(mintheta(1,:))) ;
  fprintf('\n') ;
  for i=2:k+1 ;
    fprintf('factor loadings     :'); fprintf(' % 6.4f', mintheta(i,:)') ;
    fprintf('\n') ;
  end;
  fprintf('minimum distance    : % 6.4f\n',minval) ;
  fprintf('degrees of freedom  :  %i\n',df) ;
  fprintf('chi^2 critical value: % 7.4f\n',chi2inv(.95,df)) ;
  fprintf('      p-value       : % 7.5f\n',1-chi2cdf(minval,df)) ;
end ;
end ;

fprintf('\n') ;

