function [wv,wm] = weightedVar( data, weights, varargin )
%[wv,wm] = weightedVar( data, weights, dim )
%   Find the variance of DATA weighted by WEIGHTS along dimension DIM.
%
%   DATA and WEIGHTS must be the same shape or be compatible (i.e. on
%   dimensions where they have different lengths, one must have length 1).
%
%   DIM defaults to the first dimension of DATA that is greater than 1, if
%   any, otherwise 1. 
%
%   This procedure also returns the weighted mean WM.
%
%   weightedVar( data, weights, ... NANFLAG ) will use NANFLAG (either
%   'includenan' or 'omitnan') in the same way as the Matlab function VAR.
%
%   See also: weightedMean, weightedStd, var.

    wm = weightedMean( data, weights, varargin{:} );
    wv = sum( ((data-wm).^2).*weights, varargin{:} ) ./ sum( weights, varargin{:} );
end
