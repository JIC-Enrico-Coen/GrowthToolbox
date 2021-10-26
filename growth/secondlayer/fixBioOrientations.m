function secondlayer = fixBioOrientations( secondlayer )
%secondlayer = fixBioOrientations( secondlayer )
%   Reorder the vertexes of the bio cells of m so as to give them all a
%   consistent orientation.

% Algorithm: Choose an arbitrary cell.  Declare its orientation to be
% correct.  Each correct cell defines what is the correct orientation for
% its neighbours. Repeat until the whole surface has a consistent
% orientation.

    if ~isNonemptySecondLayer( secondlayer )
        return;
    end

    numcells = length(secondlayer.cells);
    
    % Count the number of cells whose orientation we change.
    numfixes = 0;
    
    % Initially, we do not know the orientation of any cell.
    unknownOrientation = true(1,numcells);

    while 1
        % The outer loop is executed once for each connected component of
        % the cell mesh.
        
        % Pick a cell of unknown orientation.
        pending = find(unknownOrientation,1);
      % fprintf( 1, '%d unknown cells\n', length(find(unknownOrientation)) );

        % If there is none, we're finished.
        if isempty(pending), break; end

        % Deem its orientation to be correct.
        unknownOrientation(pending) = false;

        % Orient the rest of that cell's connected component.
        while ~isempty(pending)
            % Take a cell off the pending list.
            ci = pending(length(pending));
            numpending = length(pending)-1;

            % Look at each edge of the cell.
            ces = secondlayer.cells(ci).edges;
            for cei=1:length(ces)
                cei1 = ces(cei);
                v1 = secondlayer.cells(ci).vxs(cei);
                ed = secondlayer.edges(cei1,:);
                if ed(3)==ci
                    ci2 = ed(4);
                else
                    ci2 = ed(3);
                end
                if (ci2 > 0) && unknownOrientation(ci2)
                  % fprintf( 1, 'Considering ci %d ci2 %d cei %d ei %d\n', ...
                  %     ci, ci2, cei, ei );
                    % Find edge ei among the edges of cell ci2.
                    cei2 = find(secondlayer.cells(ci2).edges==cei1,1);
                    v2 = secondlayer.cells(ci2).vxs(cei2);

                    % If these vertexes are the same, the cells have
                    % opposite orientations.
                    if v1==v2
                        % Flip the orientation of cell ci2.
%                         fprintf( 1, 'Changing orientation of cell %d.\n', ci2 );
%                         secondlayer.cells(ci)
%                         secondlayer.cells(ci2)
                        numfixes = numfixes+1;
                        secondlayer.cells(ci2).vxs = secondlayer.cells(ci2).vxs( [1 end:-1:2] );
                        secondlayer.cells(ci2).edges = secondlayer.cells(ci2).edges( end:-1:1 );
                    end

                    % ci2's orientation is now known.
                    unknownOrientation( ci2 ) = false;

                    % Add it to the list of pending cells.
                    numpending = numpending+1;
                    pending(numpending) = ci2;
                end
            end
            pending = pending(1:numpending);
        end
    end
    
    % Finally, if more than half of the cells got flipped, flip the rest
    % instead.
    numOk = numcells - numfixes;
    if numfixes > numOk
      % fprintf( 1, 'Inverting every cell.\n' );
        for i=1:ads
            secondlayer.cells(i).vxs = secondlayer.cells(i).vxs( [1 end:-1:2] );
            secondlayer.cells(i).edges = secondlayer.cells(i).edges( end:-1:1 );
        end
        numfixes = numOk;
    end
    
    [secondlayer,numfixed] = fixbioedgehandedness( secondlayer );
    % secondlayer = makeSecondLayerEdgeData( secondlayer );
    
    if numfixes > 0
        fprintf( 1, '%s: flipped %d bio cells.\n', mfilename(), numfixes );
    end
end
