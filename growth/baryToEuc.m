function vxs = baryToEuc( m, cis, cbcs, offset )
%vxs = baryToEuc( m, cis, cbcs )
%   Convert barycentric coordinates to Euclidean en masse.
%   cis is a list of N element indexes.
%   cbcs is N*3, containing barycentric coordinates of a point in each
%   element.
%   vxs will be the 3D positions of these points.

    N = length(cis);
    allvxs = reshape( m.nodes( m.tricellvxs(cis,:)', : )', 3, 3, N );
    allcbcs = permute( reshape( repmat( cbcs', 3, 1 ), 3, 3, N ), [2 1 3] );
    vxs = permute( sum( allvxs.*allcbcs, 2 ), [3 1 2] );
    
    if (nargin==4) && (offset ~= 0)
        allvxs = reshape( m.prismnodes( 2*m.tricellvxs(cis,:)', : )', 3, 3, N );
        vxs2 = permute( sum( allvxs.*allcbcs, 2 ), [3 1 2] );
        vxs = vxs + offset*(vxs2-vxs);
    end
end
