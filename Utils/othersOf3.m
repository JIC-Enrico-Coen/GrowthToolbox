function [b,c] = othersOf3( a, a2 )
%bc = othersOf3( a )
%[b,c] = othersOf3( a )
%   If a is in the range 1..3, set bc or [b,c] to the successors of a.
%   a can be an array of any shape.

    if (nargin==1)
        b1 = mod(a,3)+1;
        c1 = mod(b1,3)+1;
        if nargout==2
            b = b1;  c = c1;
        else
            b = [b1(:) c1(:)];
        end
    else
        if any(a==a2)
            timedFprintf( 'Two identical axes supplied.\n' );
            bad = a==a2;
            abad = a(bad);
            a2bad = a2(bad);
            fprintf( '    %d:  %d  %d\n', [find(bad)'; abad(:)'; a2bad(:)' ] );
            a2(bad) = mod(abad,3)+1;
        end
        b = a2;
        z = zeros(numel(a),3);
        z( sub2ind( size(z), 1:numel(a), a ) ) = 1;
        z( sub2ind( size(z), 1:numel(a), a2 ) ) = 2;
        [ii,jj] = ind2sub( size(z), find(z==0) );
        jj(ii) = jj;
        c = reshape( jj, size(a) );
    end
end
