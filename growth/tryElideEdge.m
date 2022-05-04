function [m,numElided] = tryElideEdge( m )
%[m,numElided] = tryElideEdge( m )
%   Attempts to find an edge of m to elide.  It first assesses the quality
%   of each edge (the minimum angle of the cells incident on it), arranges
%   those falling below a threshold in increasing order, and then attempts
%   to elide each one in turn until one succeeds.  Elision fails if either
%   it would result in an invalid mesh, or if it would reduce the quality
%   of any cell to a value below the threshold.

    if usesNewFEs( m )
        % Different method for volumetric meshes.
        [m,numElided] = elideSmallFaces( m );
        return;
    end
    
    threshold = m.globalProps.mincellangle;
    go_on = true;
    numElided = 0;
    pass = 0;
    
    % Save the absolute positions of all the streamline vertexes.
    streamlinevxs = cell( 1, length(m.tubules.tracks) );
    for i=1:length(m.tubules.tracks)
        streamlinevxs{i} = baryToEuc( m, m.tubules.tracks(i).vxcellindex, m.tubules.tracks(i).barycoords );
    end
    
    while go_on
        pass = pass+1;
        fprintf( 1, 'Elide edges pass %d.\n', pass );
      % [eis,qualities] = findEdgesToElide( m, threshold );
        [elidesharp,elideshallow] = findElidableEdges( m, 1.3*threshold );
        fprintf( 1, 'Sharp %d, shallow %d.\n', ...
            numel(elidesharp), numel(elideshallow) );
        if isempty(elidesharp)
            fprintf( 1, 'Elide edges: no candidates.\n' );
            break;
        end
        go_on = false;
        i = 1;
        numthispass = 0;
        while i <= length(elidesharp)
            ei = elidesharp(i);
          % fprintf( 1, '%s: attempting edge %d\n ', mfilename(), ei );
            [m,elided,renumberedges] = elideEdge(m,ei,threshold);
            if elided
                numthispass = numthispass+1;
                elidesharp = renumberedges( elidesharp( (i+1):end ) );
                elidesharp = elidesharp(elidesharp ~= 0);
                i = 1;
                go_on = true;
%                 fprintf( 1, 'Num sharp remaining = %d\n', length( elidesharp ) );
            else
                i = i+1;
            end
        end
        numElided = numElided + numthispass;
        fprintf( 1, 'Elide edge pass %d: %d edges elided.\n', pass, numthispass );
    end
    if numElided==0
      % fprintf( 1, 'No edges could be elided.\n' );
    else
        % Compute the new relative positions of all the streamline vertexes.
        for i=1:length(m.tubules.tracks)
            if ~isemptystreamline( m.tubules.tracks(i) )
                vxs = streamlinevxs{i};
                for j=1:length( m.tubules.tracks(i).vxcellindex )
                    [ m.tubules.tracks(i).vxcellindex(j), m.tubules.tracks(i).barycoords(j,:) ] = ...
                        findFE( m, vxs(j,:) );
                end
                finalelement = m.tubules.tracks(i).vxcellindex(end);
                m.tubules.tracks(i).directionglobal = ...
                    vec2bc( m.tubules.tracks(i).directionbc, m.nodes( m.tricellvxs(finalelement,:), : ) );
                m.tubules.tracks(i).directionglobal = streamlineGlobalDirection( m, m.tubules.tracks(i) );
            end
        end
        [ok,m] = validmesh(m);
        if ~ok
            error('Oops!');
        end
      % fprintf( 1, 'Elided %d edges.\n', numElided );
    end
end
