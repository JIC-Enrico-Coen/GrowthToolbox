function [cells,bcs] = globalToBaryCoords( gc, nodes, triangles, normals, hint )
%[cells,bcs] = globalToBaryCoords( gc, nodes, triangles, normals, hint )
%   Convert global coordinates to barycentric coordinates.
%   GC is a K*D matrix containing K points in global coordinates.
%   NODES is an N*D matrix containing the global coordinates of a set of N
%   points in D dimensions.
%   TRIANGLES is an M*3 matrix containing the indexes of triples of nodes.
%   GC is a C*D array of global coordinates of a set of points.
%   NORMALS is an M*3 matrix giving normal vectors for all the triangles.
%   This argument can be missing or empty, in which case the normals will
%   be computed.
%   HINT, if supplied, is a C*1 array of triangle indexes or a C*1 cell
%   array of arrays of triangle indexes.
%
%   CELLS will be a C*1 or 1*C vector of indexes of triangles.
%   BCS will be a C*3 array of barycentric coordinates.  cells(i) is the
%   index of the triangle that gc(i,:) lies in.  bcs(i,:) is the
%   barycentric coordinates of that point with respect to that triangle.
%
%   See also BARYTOGLOBALCOORDS.

%   Timing tests:

    % Preprocess arguments.
    numcells = size(triangles,1);

    if (nargin < 4) || isempty(normals)
        for ci=1:numcells
            normals(ci,:) = trinormal( nodes( triangles(ci,:), : ) );
        end
    end
    if nargin < 5, hint = []; end

    % Initialise results.
    cells = int32( zeros( size(gc,1), 1 ) );
    bcs = zeros( size(gc,1), 3 );

    % HINT specifies for each point, either at most one triangle or a list of triangles
    % it might lie inside.  For each point, we test its barycentric
    % coordinates with respect to the hinted triangle for that point, and
    % if any of them give coordinates that are all positive, then that
    % triangle is chosen.
    
    if ~isempty(hint)
        if 0 && iscell(hint)
            for i=1:size(gc,1)
                for j=1:length(hint{i})
                    hintbc = baryCoords( nodes( triangles(j,:), : ), normals(j,:), gc(i,:) );
                    if all(hintbc >= 0)
                        cells(i) = j;
                        bcs(i,:) = hintbc;
                        break;
                    end
                end
            end
        else
            for i=1:size(gc,1)
                if hint(i) > 0
                    hintbc = baryCoords( nodes( triangles(hint(i),:), : ), normals(hint(i),:), gc(i,:) );
                    if all(hintbc >= 0)
                        cells(i) = hint(i);
                        bcs(i,:) = hintbc;
                    end
                end
            end
        end
    end
    
    % Brute force algorithm for remaining points.
    % Calculate the barycentric coordinates of every point with respect to
    % every cell.  Then for each point, select that cell for which the
    % minimum of its bcs over all cells is the largest.
    pointsToDo = find( cells==0 );
  % frac_pointsToDo = numel(pointsToDo)/size(cells,1)
    if ~isempty(pointsToDo)
        allbcs = zeros( numcells, length(pointsToDo), 3 );
        for ci=1:numcells
            allbcs(ci,:,:) = baryCoords( nodes( triangles(ci,:), : ), normals(ci,:), gc(pointsToDo,:) );
        end
        for i=1:length(pointsToDo)
            [y,ci] = max( min( allbcs(:,i,:), [], 3 ), [], 1 );
            cells(pointsToDo(i)) = ci;
            bcs(pointsToDo(i),:) = allbcs( ci,i,: );
        end
    end
end
