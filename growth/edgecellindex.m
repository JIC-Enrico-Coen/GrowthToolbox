function eci = edgecellindex( m )
%eci = edgecellindex( m )
%   Return an array the same size as m.edgecells, in which for every
%   nonzero value c in m.edgecells(e,i), the corresponding value of
%   eci(e,i) is such that m.tricellvxs( c, eci(e,i) ) is the vertex of
%   element c that is not in the edge e. Equivalently, m.celledges( c,
%   eci(e,i) ) is equal to e.
%
%   For foliate meshes only. Volumetric meshes return an empty array.

    if isVolumetricMesh( m )
        eci = [];
        return;
    end

    edgecell1vxs = m.tricellvxs( m.edgecells(:,1), : );
    x11 = m.edgeends(:,1)==edgecell1vxs(:,1);
    x12 = m.edgeends(:,1)==edgecell1vxs(:,2);
    x13 = m.edgeends(:,1)==edgecell1vxs(:,3);
    
    edgedatamap = m.edgecells(:,2) ~= 0;
    ec2 = m.edgecells(edgedatamap,2);
    ee2 = m.edgeends(edgedatamap,1);
    edgecell2vxs = m.tricellvxs( ec2, : );
    x21 = ee2==edgecell2vxs(:,1);
    x22 = ee2==edgecell2vxs(:,2);
    x23 = ee2==edgecell2vxs(:,3);
    
    if ~isfield( m, 'edgesense' )
        m.edgesense = edgesense( m );
    end
    es = m.edgesense;
    eci = zeros( size(m.edgecells), 'int32' );
    eci(:,1) = mod( x11*1 + x12*2 + x13*3 + es, 3 ) + 1;
    eci(edgedatamap,2) = mod( x21*1 + x22*2 + x23*3 + ~es(edgedatamap), 3 ) + 1;
    
    % Check.
    for ei=1:size(m.edgeends,1)
        for i=1:2
            ci = m.edgecells(ei,i);
            if ci > 0
                vi = m.tricellvxs( ci, eci(ei,i) );
                if any( m.edgeends(ei,:)==vi )
                    xxxx = 1;
                end
            
                if ~(m.celledges( ci, eci(ei,i) )==ei)
                    xxxx = 1;
                end
            end
        end
    end
end
