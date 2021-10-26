function m = setrestsprings( m, onlylength )
%m = setrestsprings( m )
%   Set the rest lengths and angles of all the springs to their current
%   values.  If onlylength is supplied and is true (the default is false),
%   then rest angles and hinge strengths will be set to zero.

    numedges = size(m.edgeends,1);

    edgevecs = m.nodes( m.edgeends(:,2), : ) - m.nodes( m.edgeends(:,1), : );
    edgelensq = sum( edgevecs.^2, 2 );
    m.restlengths = sqrt( edgelensq );

    nonborderedges = find( m.edgecells(:,2) ~= 0 );
    m.edgestrengths = ones( numedges, 1 );

    m.restangles = zeros(numedges,1);
    if (nargin > 1) && ~onlylength
        m.restangles(nonborderedges) = vecangle( m.unitcellnormals(m.edgecells(nonborderedges,1),:), ...
                                                 m.unitcellnormals(m.edgecells(nonborderedges,2),:) );
        m.hingestrengths = ones( numedges, 1 );
    else
        m.hingestrengths = zeros( numedges, 1 );
    end
end
