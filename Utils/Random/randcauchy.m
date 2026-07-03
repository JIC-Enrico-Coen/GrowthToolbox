function r = randcauchy( varargin )
%r = randcauchy( sz )
%r = randcauchy( sz1, sz2, ... )
%r = randcauchy( ..., type )
%   Get a random sample from the standard Cauchy distribution with median
%   zero and spread parameter 1. The spread parameter is the
%   semi-interquartile range, the Cauchy distribution having infinite
%   variance.
%
%   All the arguments are as for RAND() and RANDN(), the last one
%   optionally supplying the floating-point class, and the remainder the
%   size of the array to be returned.
%
%   See also: cdfcauchy, invcdfcauchy, pdfcauchy, rand.

    if (nargin > 0) && ischar( varargin{end} )
        classname = varargin{end};
        varargin(end) = [];
    else
        classname = 'double';
    end
    if isempty(varargin)
        sz = [1 1];
    else
        sz = cell2mat( varargin );
    end
    r = tan( pi*(rand(sz,classname)-0.5) );
end