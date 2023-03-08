function out = ranktestfun(theta,vecsigma,Vhat) ;
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
%vecsigma =  vech of cov matrix
%theta is a candidate matrix for the minimiser.

[r,k] = size(theta) ; % note that the rank being tested is r0 = r-1

sigmamat = diag(theta(1,:).^2) + theta(2:r,:)'*theta(2:r,:) ;  %overall variance covariance matrix. 
%Contains the variance covariance matrix of the factors and that of the
%white noise terms. 

tempsigma = sigmamat(find(tril(ones(size(sigmamat))))) ;
%this vectorises it.

%this is the 'test statistic'. We choose the elements of tempsigma so that this is minimised.  

out = (vecsigma -tempsigma)' /Vhat *(vecsigma -tempsigma) ;
