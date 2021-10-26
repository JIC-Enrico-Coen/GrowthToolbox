function [wts,pts,pos] = butterflystencil( m, ei, surfacetension, edgetension )
%[wts,pts,pos] = butterflystencil( m, ei, surfacetension, edgetension )
%   Find the stencil resulting from subdividing edge ei by
%   the butterfly algorithm.  If not supplied, surfacetension and
%   edgetension are taken from m.globalProps.

    if nargin < 3
        surfacetension = m.globalProps.surfacetension;
    end
    if nargin < 4
        edgetension = m.globalProps.edgetension;
    end

    c2 = m.edgecells( ei, 2 );
    
    if c2==0
      % fprintf( 1, 'butterfly: edge of mesh\n');
        [wts,pts] = edgesplinewts( m, ei, edgetension );
        pos = wts*m.nodes(pts,:);
        return;
    end
    
    if surfacetension==0
        wts = [ 1/2 1/2 ];
        pts = m.edgeends( ei, : );
    else
        wts = [ 1/2 1/2 surfacetension*2 surfacetension*2 -surfacetension -surfacetension -surfacetension -surfacetension ];
        pts = [ m.edgeends( ei, : ), zeros(1,6) ];
        
        c1 = m.edgecells( ei, 1 );
        pts(3) = othervertex( m, c1, pts(1), pts(2) );

        e11 = m.celledges( c1, m.tricellvxs(c1,:)==pts(2) );
        c11 = othercell( m, c1, e11 );
        if c11 == 0
            wts([1 2 3]) = wts([1 2 3]) + wts(5)*[1 -1 1];
            wts(5) = 0;
        else
            pts(5) = m.tricellvxs( c11, m.celledges(c11,:)==e11 );
        end

        e12 = m.celledges( c1, m.tricellvxs(c1,:)==pts(1) );
        c12 = othercell( m, c1, e12 );
        if c12 == 0
            wts([1 2 3]) = wts([1 2 3]) + wts(6)*[-1 1 1];
            wts(6) = 0;
        else
            pts(6) = m.tricellvxs( c12, m.celledges(c12,:)==e12 );
        end

        pts(4) = othervertex( m, c2, pts(1), pts(2) );

        e21 = m.celledges( c2, m.tricellvxs(c2,:)==pts(2) );
        c21 = othercell( m, c2, e21 );
        if c21 == 0
            wts([1 2 4]) = wts([1 2 4]) + wts(7)*[1 -1 1];
            wts(7) = 0;
        else
            pts(7) = m.tricellvxs( c21, m.celledges(c21,:)==e21 );
        end

        e22 = m.celledges( c2, m.tricellvxs(c2,:)==pts(1) );
        c22 = othercell( m, c2, e22 );
        if c22 == 0
            wts([1 2 4]) = wts([1 2 4]) + wts(8)*[-1 1 1];
            wts(8) = 0;
        else
            pts(8) = m.tricellvxs( c22, m.celledges(c22,:)==e22 );
        end

        wts = wts(pts ~= 0);
        pts = pts(pts ~= 0);
%         if length(unique(pts)) < length(pts)
%             xxxx = 1;
%         end
    end
    
    pos = wts*m.nodes(pts,:);
end
