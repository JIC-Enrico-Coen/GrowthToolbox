function [edgeperm,faceperm] = vxPermtoEdgefacePerm( vxperm, fe )
    [xx,edgeperm0] = sortrows( sort(fe.edges,1)' );
    [yy,faceperm0] = sortrows( sort(fe.faces,1)' );
    [xx,edgeperm1] = sortrows( sort( vxperm(fe.edges'), 2 ) );
    [yy,faceperm1] = sortrows( sort( vxperm(fe.faces'), 2 ) );
    edgeperm(edgeperm1) = edgeperm0';
    faceperm(faceperm1) = faceperm0';
end
