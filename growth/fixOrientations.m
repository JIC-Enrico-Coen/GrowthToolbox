function m = fixOrientations( m )
%m = fixOrientations( m )
%   Reorder the vertexes of the cells of m so as to give them all a
%   consistent orientation.

% Algorithm: Choose an arbitrary cell.  Declare its orientation to be
% correct.  Each correct cell defines what is the correct orientation for
% its neighbours. Repeat until the whole surface has a consistent
% orientation.

    numcells = size(m.tricellvxs,1);
    
    othercells = reshape( m.edgecells( m.celledges, 1 ), size(m.celledges) );
    secondcells = reshape( m.edgecells( m.celledges, 2 ), size(m.celledges) );
    needother = othercells == repmat( (1:numcells)', 1, 3 );
    othercells(needother) = secondcells( needother );
    % For each cell ci, othercells(ci,:) lists the cells that are on the
    % other side of the three edges of cell ci.
    
    % Count the number of cells whose orientation we change.
    numfixes = 0;
    
    % Initially, we do not know the orientation of any cell.
    unknownOrientation = true(1,numcells);
    nextof3 = [2 3 1];

    while 1
        % The outer loop is executed once for each connected component of
        % the mesh.
        
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
            for cei=1:3
                ei = m.celledges(ci,cei);

                % Find the cell on the other side of that edge.
                ci2 = othercells(ci,cei);                    

                % If it exists and has unknown orientation...
                if (ci2>0) && unknownOrientation(ci2)
                  % fprintf( 1, 'Considering ci %d ci2 %d cei %d ei %d\n', ...
                  %     ci, ci2, cei, ei );
                    % Find edge ei among the edges of cell ci2.
                    cei2 = find(m.celledges(ci2,:)==ei);

                    % Find the vertexes at the first end of edge ei in
                    % each of the two cells.
                    cei1i = nextof3(cei); % mod(cei,3)+1;
                    cei2i = nextof3(cei2); % mod(cei2,3)+1;
                    v1 = m.tricellvxs(ci,cei1i);
                    v2 = m.tricellvxs(ci2,cei2i);

                    % If these vertexes are the same, the cells have
                    % opposite orientations.
                    if v1==v2
                        % Flip the orientation of cell ci2.
                      % fprintf( 1, 'Changing orientation of cell %d.\n', ci2 );
                        numfixes = numfixes+1;
                        m.celledges(ci2,:) = m.celledges(ci2,[1 3 2]);
                        m.tricellvxs(ci2,:) = m.tricellvxs(ci2,[1 3 2]);
                        if isfield( m, 'unitcellnormals' )
                            m.unitcellnormals(ci2,:) = -m.unitcellnormals(ci2,:);
                        end
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
        m.celledges(:,:) = m.celledges(:,[1 3 2]);
        m.tricellvxs(:,:) = m.tricellvxs(:,[1 3 2]);
        if isfield( m, 'unitcellnormals' )
            m.unitcellnormals = -m.unitcellnormals;
        end
        numfixes = numOk;
    end
    
    if numfixes > 0
        fprintf( 1, '%s: flipped %d cells.\n', mfilename(), numfixes );
    end
end
