function [x,y] = randCorr( c, sz )
%[x,y] = randCorr( c, sz )
%   Generate random samples from a bivariate normal distribution for which
%   the means of both variables are 0, their marginal standard deviations
%   are 1, and their correlation is c (in the range -1...1). The results x
%   and y have the given size (by default 1).
%
%   If c is outside -1...1, it will be truncated to that range.
%   If c has an imaginary component it will be ignored.
%
%   If c is not a single number, it must be an array of shape SZ, or
%   compatible with SZ in the sense of either possibly having size 1 along
%   dimensions where the other has size greater than 1.
%   Samples will be drawn for each respective value in c.

    if nargin < 2
        sz = [1 1];
    elseif length(sz)==1
        sz = [sz 1];
    else
        sz = sz(:)';
    end
    
    % Sanity check.
    c = max(-1,min(1,real(c)));
    
    % Parameters for transforming the c==0 distribution.
    theta = 0.5*asin(c);
    a = cos(theta);
    b = sin(theta);
    
    % Generate the samples.
    r1 = randn( sz );
    r2 = randn( sz );
    x = a.*r1 + b.*r2;
    y = b.*r1 + a.*r2;
end
