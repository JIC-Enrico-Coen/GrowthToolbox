function r = randreciprocal( scale, varargin )
%r = randreciprocal( sz, type )
%   Get a random sample from the reciprocal distribution, whose cumulative
%   distribution function is 1-1./(1+SCALE*x), where SCALE >= 0.
%
%   The larger is SCALE, the wider is the spread of the results. If
%   SCALE=0, the results are all zero.

    if (nargin > 1) && ischar( varargin{end} )
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
    
    if scale <= 0
        r = zeros(sz,classname);
    else
        r = (1./(1 - rand(sz,classname)) - 1) * scale;
    end
end