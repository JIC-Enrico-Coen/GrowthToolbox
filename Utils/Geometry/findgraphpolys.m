function [polys,vvxs,vedges] = findgraphpolys( vxs, edges )
%polys = findpolys( vxs, edges )
%   Given a set of vertex positions and a set of edges joining them, and
%   assuming that the whole is a planar graph, find the polygons.
%   VXS is an N*2 aray of vertex positions in the plane.
%   EDGES is an M*2 list of pairs of vertexes.
%   POLYS will be a cell array of arrays of vertexes.
%   VVXS is a list of the neighbours of each vertex, in anticlockwise order
%   of direction, starting from -180 degrees.
%   VEDGES is a list of the directed edges incident on each vertex, in the
%   same order as VEDGES.
%   If the graph is not planar, empty arrays are returned.

    % 1. Convert the edge list into a list of directed edges.
    dedges = [ edges; edges(:,[2 1]) ];
    
    % 2. Create a table to record which directed edges have been assigned
    % to a polygon.
    assigned = false( size(dedges,1), 1 );
    
    % 3. Create a table recording which directed edges impinge on each
    % vertex, and what the neighbouring vertexes are.
    vedges = cell( size(vxs,1),1 );
    vvxs = cell( size(vxs,1),1 );
    for ei=1:size(dedges,1)
        v1 = dedges(ei,2);
        vedges{v1}(length(vedges{v1})+1) = ei;
        vvxs{v1}(length(vvxs{v1})+1) = dedges(ei,1);
    end
    
    % 4. Sort the edge and vertex lists for each vertex.
    for vi=1:size(vxs,1)
        ne = length(vedges{vi});
        a = zeros(1,ne);
        for ei=1:ne
            vec = vxs(dedges(vedges{vi}(ei),1),:) - vxs(vi,:);
            a(ei) = atan2( vec(2), vec(1) );
        end
        [as,ap] = sort(a);
        vedges{vi} = vedges{vi}(ap);
        vvxs{vi} = vvxs{vi}(ap);
    end
    
    % 5. Search the table to find an unassigned edge, and generate a
    % polygon from it.
    polys = cell(0);
    np = 0;
    for ei=1:length(assigned)
        if ~assigned(ei)
            newpoly = dedges( ei, [2,1] );
            assigned(ei) = true;
            startvx = newpoly(1);
            prevvx = startvx;
            curvx = newpoly(2);
            while curvx ~= startvx
                vvi = find( vvxs{curvx}==prevvx, 1 );
                vvi = vvi-1;
                if vvi==0, vvi = length(vvxs{curvx}); end
                vi = vvxs{curvx}(vvi);
                ei1 = vedges{curvx}(vvi);
                if assigned(ei1)
                    fprintf( 1, 'Reassigning edge %d (%d,%d)!\n', ...
                        ei1, curvx, vvi );
                    polys = cell(0);
                    vvxs = cell(0,1);
                    vedges = cell(0,1);
                    return;
                end
                assigned(ei1) = true;
                prevvx = curvx;
                curvx = vi;
                if vi ~= startvx
                    newpoly(length(newpoly)+1) = vi;
                end
            end
            np = np+1;
            polys{np} = newpoly;
        end
    end
end
