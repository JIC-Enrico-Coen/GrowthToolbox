function m = springforces( m, onlylength )
%asd = springforces( m, onlylength )
%   Calculate the force on each node resulting from the springs of m.

%   m must contain for each edge a rest length and a rest angle for that
%   edge: m.restlengths and m.restangles.  The latter is only significant
%   for edges not on the boundary of the mesh.  Spring constants are
%   m.edgestrengths and m.hingestrengths.
%
%   If onlylength is true (the default is false), then hinges will be
%   ignored.

    numnodes = size(m.nodes,1);
    numedges = size(m.edgeends,1);
    m.nodeforces = zeros( numnodes, 3 );
    
    edgevecs = m.nodes( m.edgeends(:,2), : ) - m.nodes( m.edgeends(:,1), : );
    edgelensq = sum( edgevecs.^2, 2 );
    edgelens = sqrt( edgelensq );
    edgeforcesize = (edgelens - m.restlengths) .* m.edgestrengths;
    for ei=1:numedges
        n1 = m.edgeends(ei,1);
        n2 = m.edgeends(ei,2);
        f = (edgeforcesize(ei)/edgelens(ei)) * edgevecs(ei,:);
        m.nodeforces(n1,:) = m.nodeforces(n1,:) + f;
        m.nodeforces(n2,:) = m.nodeforces(n2,:) - f;
    end
    
  % m.nodeforces = zeros( numnodes, 3 );

    if (nargin < 2) || ~onlylength
        nonborderedges = find( m.edgecells(:,2) ~= 0 );
        angles = zeros(numedges,1);
        angles(nonborderedges) = vecangle( m.unitcellnormals(m.edgecells(nonborderedges,1),:), ...
                                           m.unitcellnormals(m.edgecells(nonborderedges,2),:) );
        hingetorques = (angles - m.restangles) .* m.hingestrengths;
      % springforces_angles = angles';
      % max_springforces_angles = max(abs(springforces_angles))
      % springforces_hingetorques = hingetorques';
      % max_springforces_hingetorques = max(abs(springforces_hingetorques))
        for ei=nonborderedges'
            vi1 = m.edgeends( ei, 1 );
            vi2 = m.edgeends( ei, 2 );
            c1 = m.edgecells( ei, 1 );
            c2 = m.edgecells( ei, 2 );
            cei1 = find( m.celledges(c1,:)==ei );
            if m.tricellvxs( c1, mod(cei1,3)+1 )==vi2
                temp = vi2;
                vi2 = vi1;
                vi1 = temp;
            end
            cei2 = find( m.celledges(c2,:)==ei );
            vi3 = m.tricellvxs( c1, cei1 );
            vi4 = m.tricellvxs( c2, cei2 );
            forces = fourpointforce( ...
                hingetorques(ei), ...
                m.nodes([vi1 vi2 vi3 vi4],:), ...
                m.unitcellnormals(c1,:), ...
                m.unitcellnormals(c2,:) );
            m.nodeforces( [vi1 vi2 vi3 vi4], : ) = m.nodeforces( [vi1 vi2 vi3 vi4], : ) + forces;
        end
    end
  % springforces_nodeforces = m.nodeforces;
  % max_springforces_nodeforces = max(abs(springforces_nodeforces(:)))
end
