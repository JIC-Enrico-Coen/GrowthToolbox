function vxnbs = vxVxNbs( m )
%vxnbs = vxVxNbs( m )
%   For every vertex of the mesh m, find all of its neighbouring vertexes.
%
%   The result is a cell array mapping each vertex to a list of its
%   neighbours.

    numvxs = getNumberOfVertexes( m );
    if isVolumetricMesh( m )
        ee = m.FEconnectivity.edgeends;
    else
        ee = m.edgeends;
    end
    
    e1 = sort( ee, 2 );
    e1 = [ e1; e1( :, [2 1] ) ];
    e1 = sortrows( e1 );
    [starts,ends] = runends( e1(:,1) );
    vxnbs = cell( numvxs, 1 );
    for nvi=1:numvxs
        vi = e1(starts(nvi),1);
        vxnbs{vi} = e1( starts(nvi):ends(nvi), 2 );
    end
end