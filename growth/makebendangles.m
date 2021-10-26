function m = makebendangles( m, es )
%m = makebendangles( m, es )
%   Calculate the angle between element normals across the edges es, by
%   default all of them.  For boundary edges this is set to zero.  

    if nargin < 2
        numedges = size( m.edgeends, 1 );
        es = 1:numedges;
        m.currentbendangle = zeros( numedges, 1, 'single' );
    else
        numedges = length(es);
        m.currentbendangle(es,1) = zeros( numedges, 1, 'single' );
    end
    if (isfield( m.globalProps, 'alwaysFlat' ) && m.globalProps.alwaysFlat) || (isfield( m.globalProps, 'twoD' ) && m.globalProps.twoD)
        return;
    end
    for i=1:numedges
        ei = es(i);
        c2 = m.edgecells(ei,2);
        if c2
            c1 = m.edgecells(ei,1);
            m.currentbendangle(ei) = ...
                vecangle( m.unitcellnormals( c1, : ), m.unitcellnormals( c2, : ) );
        end
    end
end
