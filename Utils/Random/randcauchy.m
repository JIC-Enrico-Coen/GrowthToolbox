function r = randcauchy( varargin )
%r = randcauchy( sz )
%   Get a random sample from the standard Cauchy distribution with median
%   zero and spread parameter 1.
%
%   The final argument can be a class name specifying the type of the
%   result; by default, 'double'.
%
%   See also: cdfcauchy, invcdfcauchy, pdfcauchy.

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