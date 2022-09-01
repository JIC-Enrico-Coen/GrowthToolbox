function [newbc,newdirbc] = transferDirection( m, ci, bc, dirbc, nextci )
%newdirbc = transferDirection( m, ci, dirbc, nextci )
%   A direction dirbc at a point bc of element ci is to be transferred to
%   element nextci, which shares an edge with ci, the edge on which the
%   point bc is.

    fevxs = m.nodes( m.tricellvxs(ci,:), : );
    nextfevxs = m.nodes( m.tricellvxs(nextci,:), : );
    dirglobal = dirbc * fevxs;
    bci = find(bc<=0,1);
    ei = m.celledges( ci, bci );
    whichedgecell = int32(1 + (m.edgecells(ei,2)==ci));
    eis = m.edgesense( ei ) == (whichedgecell==1);
    neweci = find(m.celledges(nextci,:)==ei,1);
    [bcj,bck] = othersOf3( bci );
    [newecj,neweck] = othersOf3( neweci );
    newbc( [neweci,neweck,newecj] ) = bc( [bci,bcj,bck] );
    newvj = m.tricellvxs( nextci, newecj );
    newvk = m.tricellvxs( nextci, neweck );
    
%     oldvx = bc * m.nodes( m.tricellvxs( ci, : ), : )
%     newvx = newbc * m.nodes( m.tricellvxs( nextci, : ), : )
    
    
    if ~isfield( m, 'vertexnormals' ) || isempty( m.vertexnormals )
        m.vertexnormals = meshVertexNormals( m );
    end
    
    vxn1 = m.vertexnormals( newvj, : );
    vxn2 = m.vertexnormals( newvk, : );
    
    INTERPOLATED_NORMALS = true;
    if INTERPOLATED_NORMALS
        vxn = newbc(newecj)*vxn1 + newbc(neweck)*vxn2;
    else
        vxn = (vxn1 + vxn2)/2;
    end
    vxn = vxn/norm(vxn);
    
    % Project dirglobal onto the plane perpendicular to vxn.
    % Then project it onto the next FE and get its barycentric coordinates.
    % Or put differently, take the plane common to vxn and dirglobal, and
    % find its intersection with the plane of the next FE.
    % This will do it: nextdirglobal = (dirglobal X vxn) X nextfenormal
    
    nextfenormal = trinormal( nextfevxs );
    nextdirglobal = cross( nextfenormal, cross( dirglobal, vxn ) );
    nextdirglobal = nextdirglobal/norm(nextdirglobal);
    if any(isnan(nextdirglobal))
        xxxx = 1;
    end
    
    % Convert nextdirglobal to dbcs.
%     newdirbc = baryCoords( nextfevxs, nextfenormal, nextdirglobal + nextfevxs(1,:), false );
%     newdirbc = newdirbc - [1 0 0];
    
    newdirbc = baryDirCoords( nextfevxs, nextfenormal, nextdirglobal );
end
