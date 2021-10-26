function [sharpedges,shallowedges] = findElidableEdges( m, threshold )
    vertexes = reshape( m.nodes( m.tricellvxs', : ), 3, [], 3 );
    % Indexed by vertex, cell, and xyz.
    
    edgevecs = vertexes( [3 1 2], :, : ) - vertexes( [2 3 1], :, : );
    % Indexed by edge, cell, and xyz.
    
    edgelensq = sum( edgevecs.^2, 3 )';
    % Indexed by cell and edge.
    
    maxedgelensq = max( edgelensq, [], 2 );
    [minedgelensq,mini] = min( edgelensq, [], 2 );
    % Indexed by cell and 1.
    
    sharpness = minedgelensq ./ maxedgelensq;
    % Indexed by cell and 1.
    
    % An edge is sharp if it is the short edge of the cells on each side on
    % which it has a cell.
    sharpcells = sharpness < threshold*threshold;
    edgesharpness = int16(m.edgecells(:,2)==0);
    for ci=find(sharpcells)'
        ei = m.celledges(ci,mini(ci));
        edgesharpness(ei) = edgesharpness(ei)+1;
    end
    sharpedges = find( edgesharpness==2 );
    
    shallowedges = [];
    return;
    % We find in practice that very few cells pass the shallowness test,
    % and mesh quality is maintained without it.
  
    shallowquality = repmat( m.cellareas, 1, 3 ) ./ edgelensq;

    if false
        edgemidpoints = (vertexes([2 3 1],:,:) + vertexes([3 1 2],:,:))/2;
        medians = vertexes - edgemidpoints;
        medianlengthsq = sum( medians.*medians, 3 )';
        % Indexed by cell and edge.

        shallowquality = medianlengthsq ./ edgelensq;
    end
    % Indexed by cell and 1.
    [shallowness,shallowi] = min( shallowquality, [], 2 );
    shallowcells = shallowness < (threshold^2)/4;
    edgeshallowness = int16(m.edgecells(:,2)==0);
    for ci=find(shallowcells)'
        ei = m.celledges(ci,shallowi(ci));
        edgeshallowness(ei) = edgeshallowness(ei)+1;
    end
    shallowedges = find( (edgeshallowness==2) & (edgesharpness < 2) );
end
