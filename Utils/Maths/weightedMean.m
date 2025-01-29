function wm = weightedMean( data, weights, varargin )
%wm = weightedMean( data, weights, dim )
%   Find the mean of DATA weighted by WEIGHTS along dimension DIM.
%
%   DATA and WEIGHTS must be the same shape or be compatible (i.e. on
%   dimensions where they have different lengths, one must have length 1).
%
%   DIM defaults to the first dimension of DATA that is greater than 1, if
%   any, otherwise 1.
%
%   weightedMean( data, weights, ... NANFLAG ) will use NANFLAG (either
%   'includenan' or 'omitnan') in the same way as the Matlab function MEAN.
%
%   See also: weightedStd, weightedVar, mean.

    wm = sum( data.*weights, varargin{:} ) ./ sum( weights, varargin{:} );
end
