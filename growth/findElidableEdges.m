function [elidesharp,elideshallow] = findElidableEdges( m, threshold )
%[elidesharp,elideshallow] = findElidableEdges( m, threshold )
%   For foliate meshes only.

    vertexes = reshape( m.nodes( m.tricellvxs', : ), 3, [], 3 );
    % Indexed by vertex, element, and xyz.
    
    edgevecs = vertexes( [3 1 2], :, : ) - vertexes( [2 3 1], :, : );
    % Indexed by edge, element, and xyz.
    
    edgelensq = sum( edgevecs.^2, 3 )';
    % Indexed by element and edge.
    
    maxedgelensq = max( edgelensq, [], 2 );
    [minedgelensq,mini] = min( edgelensq, [], 2 );
    % Indexed by element and 1.
    
    sharpness = minedgelensq ./ maxedgelensq;
    % Indexed by element and 1.
    
    % An edge is sharp if it is a sharp edge of all the elements it belongs
    % to.
    sharpelements = sharpness < threshold*threshold;
    edgesharpness = int16(m.edgecells(:,2)==0);
    for ci=find(sharpelements)'
        ei = m.celledges(ci,mini(ci));
        edgesharpness(ei) = edgesharpness(ei)+1;
    end
    elidesharp = find( edgesharpness==2 );
    
    elideshallow = [];
    return;
    
    % We find in practice that very few elements pass the shallowness test,
    % and mesh quality is maintained without it. So the following code is
    % not executed.
  
    shallowquality = repmat( m.cellareas, 1, 3 ) ./ edgelensq;

    if false
        edgemidpoints = (vertexes([2 3 1],:,:) + vertexes([3 1 2],:,:))/2;
        medians = vertexes - edgemidpoints;
        medianlengthsq = sum( medians.*medians, 3 )';
        % Indexed by element and edge.

        shallowquality = medianlengthsq ./ edgelensq;
    end
    % Indexed by element and 1.
    [shallowness,shallowi] = min( shallowquality, [], 2 );
    shallowelements = shallowness < (threshold^2)/4;
    edgeshallowness = int16(m.edgecells(:,2)==0);
    for ci=find(shallowcells)'
        ei = m.celledges(ci,shallowi(ci));
        edgeshallowness(ei) = edgeshallowness(ei)+1;
    end
    elideshallow = find( (edgeshallowness==2) & (edgesharpness < 2) );
end
