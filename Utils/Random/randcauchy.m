function r = randcauchy( varargin )
%r = randcauchy( sz, type )
%   Get a random sample from the standard Cauchy distribution with median
%   zero and spread parameter 1.
%
%   The optional TYPE argument is a class name specifying the type of the
%   result; by default, 'double'. All types valid for RAND() are valid.
%
%   See also: cdfcauchy, invcdfcauchy, pdfcauchy, rand

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