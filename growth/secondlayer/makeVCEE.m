function vcee = makeVCEE( m )
%vcee = makeVCEE( m )
%   Construct an N*4 array VCEE, in which each row lists a vertex, a cell,
%   and two edges of the bio layer. The vertex belongs to the cell, and the
%   two edges are consecutive edges of that cell, both containing that
%   vertex.  The edges are listed in the same order as they are in the
%   m.secondlayer.cells structure.
%
%   N is equal to the total number of corners of cells.

    numcells = length( m.secondlayer.cells );
    vcee = zeros( numcells*6, 4 ); % Estimated size for first dimension.
    vcee_n = 0;
    for c=1:numcells
        e2 = m.secondlayer.cells(c).edges';
        e1 = e2( [ end 1:(end-1) ] );
        v = m.secondlayer.cells(c).vxs';
        nv = length(v);
        newvcee = [ v, c+zeros(nv,1), e1, e2 ];
        vcee( (vcee_n+1):(vcee_n+nv), : ) = newvcee;
        vcee_n = vcee_n+nv;
    end
    vcee( (vcee_n+1):end, : ) = [];
end
