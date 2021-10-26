function [m,renumber] = stitchmeshes( m1, m2, b1, b2 )
%[m,renumber] = stitchmeshes( m1, m2, b1, b2 )
%   Stitch the two meshes together along b1 and b2.
%   b1 and b2 are lists of node indexes of the same length, of m1 and m2
%   respectively.  The mesh m2 will be translated, rotated and scaled to
%   bring the b2 nodes into coincidence with the b1 nodes.
%   renumber will be set to an array such that renumber(i) is the index in
%   the stitched mesh of node i of m2.  The indexes of nodes in m1 are
%   preserved.

    [mx,m2n] = pointTransform( ...
                 m2.nodes(b2(1),[1 2]), ...
                 m2.nodes(b2(length(b2)),[1 2]), ...
                 m1.nodes(b1(1),[1 2]), ...
                 m1.nodes(b1(length(b1)),[1 2]), ...
                 m2.nodes );
    m2.nodes = m2n;
    m = unionmesh( m1, m2 );
    [m,renumber] = stitchmesh( m, b1, b2+size(m1.nodes,1) );
    renumber = renumber( size(m1.nodes,1)+1 : length(renumber) );
end
