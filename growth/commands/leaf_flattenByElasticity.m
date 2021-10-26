function m = leaf_flattenX( m, varargin )
%m = leaf_flatten( m )
%   Flatten each of the connected components of m.
%
%   Options:
%       ratio: This is the proportion of the flattening displacements to
%              apply.  The default value is 1, i.e. complete flattening.
%
%   Topics: OBSOLETE, Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'ratio', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'ratio' );
    if ~ok, return; end

    cc = connectedComponents( m );
    numnodes = size(m.nodes,1);
    delta = m.prismnodes( 2:2:(numnodes*2), : ) - m.prismnodes( 1:2:(numnodes*2-1), : );
    delta = sqrt(sum( delta.*delta, 2 ))/2;
    for i=1:length(cc)
        vxs = unique( m.tricellvxs( cc{i}, : ) );
        centroid = sum( m.nodes(vxs,:).^2, 1 )/length(vxs);
        project = sum( m.unitcellnormals( cc{i}, : ), 1 )/length(cc{i});
        m.nodes(vxs,:) = projectPointToPlane2( m.nodes(vxs,:), project, centroid, s.ratio );
        deltap = delta(vxs)*project;
        pvxs = vxs*2;
        m.prismnodes(pvxs,:) = m.nodes(vxs,:) + deltap;
        m.prismnodes(pvxs-1,:) = m.nodes(vxs,:) - deltap;
    end
    m = recalc3d( m );
end
