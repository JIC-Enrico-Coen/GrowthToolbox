function m = leaf_smooth( m, varargin )
%m = leaf_smooth( m, ... )
%   Smooth the vertexes of m.  An amount of 0 does
%   nothing.  An amount of 1 simultaneously moves each vertex to the
%   average position of its immediate neighbours.  Values are not limited
%   to the range 0 to 1.
%
%   Options:
%   'amount'    A real number, the amount of smoothing.  Default is 1.
%   'rectify'   If true, call leaf_rectifyverticals after the smoothing.
%               Default is false. 
%
%   See also: leaf_rectifyverticals
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'amount', 1, ...
        'rectify', false );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'amount', ...
        'rectify' );
    if ~ok, return; end

    numvxs = size(m.nodes,1);
    newprismnodes = m.prismnodes;
    a = 1-amount;
    for i=1:numvxs
        ii = i*2;
        nce = m.nodecelledges{i};
        if nce(2,end) > 0
            eis = nce(1,:);
            nbs = unique( m.edgeends(eis,:) );
            nbs = nbs(nbs ~= i);
            nbs = nbs*2;
            vxs = m.prismnodes(nbs,:);
            newprismnodes(ii,:) = a*newprismnodes(ii,:) + amount*sum(vxs,1)/size(vxs,1);
            vxs = m.prismnodes(nbs-1,:);
            newprismnodes(ii-1,:) = a*newprismnodes(ii-1,:) + amount*sum(vxs,1)/size(vxs,1);
        end
    end
    m.prismnodes = newprismnodes;
    m.nodes = (m.prismnodes(1:2:end,:) + m.prismnodes(2:2:end,:))/2;
    m = leaf_rectifyverticals(m);
end
