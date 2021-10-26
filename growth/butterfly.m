function [pos,prismpos] = butterfly( m, ei, surfacetension, edgetension )
%[pos,prismpos] = butterfly( m, ei, tension )
%   Find the location of the point resulting from subdividing edge ei by
%   the butterfly algorithm.

    if nargin < 3
        surfacetension = m.globalProps.surfacetension;
    end
    if nargin < 4
        edgetension = m.globalProps.edgetension;
    end

    if nargin < 3
        tension = 1/16;
    end
    
    [wts,pts] = butterflystencil( m, ei, surfacetension, edgetension );
    pos = wts*m.nodes(pts,:);
    if nargout >= 2
        pts = pts*2;
        prismpos = [ wts*m.prismnodes(pts-1,:); wts*m.prismnodes(pts,:) ];
    end
end
