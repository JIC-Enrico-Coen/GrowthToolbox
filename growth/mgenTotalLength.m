function result = mgenTotalLength( m, mgen, threshold )
%result = mgenTotalLength( m, mgen, threshold )
%   This returns the total length of all edges of the mesh for which both
%   endpoints have a value for the given morphogen strictly greater than
%   the threshold.  If multiple morphogens are given, an array of results
%   is returned.
%
%   The threshold defaults to 0.
%
%   The morphogen can be specified either as an index or a name.  It is
%   also possible to specify a vector of values, one per vertex of the
%   triangle mesh, instead of a morphogen.
%
%   Multiple morphogens can be specified.  In this case, they must be
%   either all indexes, or all names, or an N*K array of values where N is
%   the number of vertexes and K is the number of morphogens.
%
%   See also:
%       mgenTotalArea, mgenTotalAmount.

    if nargin < 3
        threshold = 0;
    end
    if ~ischar(mgen) && (size(mgen,1)==size(m.morphogens,1))
        val = mgen;
    else
        mgen = FindMorphogenIndex( m, mgen );
        if isempty(mgen)
            result = 0;
            return;
        end
        val = m.morphogens(:,mgen);
    end
    
    result = zeros( 1, size(val,2) );
    for i=1:size(val,2)
    
        % Find the edges satisfying the threshold condition at both ends.
        mgen_edges = all( reshape( val( m.edgeends, i ), [], 2 ) > threshold, 2 );

        % Find the positions of the vertexes at the ends of those edges.
        mgen_edgepositions = reshape( m.nodes( m.edgeends( mgen_edges, : )', : ), 2, [], 3 );

        % Calculate the lengths of all of those edges.
        mgen_edgelengths = sqrt( squeeze( sum( (mgen_edgepositions(2,:,:) - mgen_edgepositions(1,:,:)).^2, 3 ) ) );

        % Return the sum of the lengths.
        result(i) = sum( mgen_edgelengths );
    end
end
