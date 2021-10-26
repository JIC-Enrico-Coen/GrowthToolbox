function nb = surfaceNeighbours( s )
%nb = surfaceNeighbours( s )
%   %   Given a surface S as returned by isosurface(), return a cell array
%   listing for each vertex, the indexes of its neighbours.

    nb = cell( 1, size(s.vertices,1) );
    for i=1:size(s.faces,1)
        fi = s.faces(i,:);
        for j=1:size(s.faces,2)
            fij = fi(j);
            nb{fij} = [ nb{fij} fi ];
        end
    end
    for i=1:size(s.vertices,1)
        nb{i} = unique(nb{i});
    end
end

