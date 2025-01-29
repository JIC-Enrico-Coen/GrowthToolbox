function [ws,wv,wm] = weightedStd( data, weights, varargin )
%[ws,wv,wm] = weightedStd( data, weights, dim )
%   Find the standard deviation of DATA weighted by WEIGHTS along dimension
%   DIM.
%
%   DATA and WEIGHTS must be the same shape or be compatible (i.e. on
%   dimensions where they have different lengths, one must have length 1).
%
%   DIM defaults to the first dimension of DATA that is greater than 1, if
%   any, otherwise 1. 
%
%   This procedure also returns the weighted variance WV and the weighted
%   mean WM.
%
%   weightedStd( data, weights, ... NANFLAG ) will use NANFLAG (either
%   'includenan' or 'omitnan') in the same way as the Matlab function STD.
%
%   See also: weightedMean, weightedVar, std.

    [wv,wm] = weightedVar( data, weights, varargin{:} );
    ws = sqrt(wv);
end
