function m = leaf_growICSpaces( m, varargin )
%m = leaf_growICSpaces( m, varargin )
%   Grow all intercellular spaces in m by a specified amount.
%
%   Options:
%
%   There are two ways in which the amount of growth can be specified.  One
%   is by these two options:
%
%   'abssize', 'relsize': These are the same as for leaf_initiateICSpaces.
%
%   The other is by specifying the amount in the form of a tissue
%   morphogen, a cellular morphogen, a vector giving an amount per mesh
%   vertex, a vector giving an amount per cell, or a vector giving an
%   amount per cell vertex.  The amount, however specified, is understood
%   as an absolute distance.
%
%   'amount':  The amount, which can be the name of a tissue morphogen, the
%       name of a cellular morphogen, or a vector, the interpretation of
%       which is determined by the 'amounttype' option.
%
%   'amounttype': One of the following strings:
%       'tissue' specifies that the amount is either the name of a
%           tissue morphogen or a value per mesh vertex.
%       'cellvertex' specifies that the amount is a value per cell vertex.
%       If 'amount' is a single value, it will be replicated as necessary
%       to make up the number of mesh vertexes or cell vertexes.
%
%   'amountmode': One of the following strings:
%       'absdist': the amount is the absolute distance that each vertex
%                  moves
%       'reldist': the amount is the distance relative to the current
%                  distance of each OC space vertex from the centroid of
%                  that IC space.
%
%   If 'amount' is given, then:
%       'abssize' and 'relsize' will be ignored,
%   	'amounttype' must also be given, and
%   	'amountmode' defaults to 'absdist'.
%
%   Negative amounts will be treated as zero.
%
%   See also: leaf_initiateICSpaces
%
%   Topics: Bio layer.

% Unsupported 'amounttype' value:
%       'cellular' specifies that the amount is either the name of a
%           cellular morphogen or a value per cell.


    if isempty( m.secondlayer.cells )
        return;
    end

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'abssize', [], 'relsize', [], 'amount', [], 'amounttype', [], 'amountmode', 'absdist' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'abssize', 'relsize', 'amount', 'amounttype', 'amountmode' );
    if ~ok, return; end
    
    if isempty(s.amount)
        if isempty( s.abssize )
            if isempty( s.relsize )
                s.relsize = 0.05;
            end
            vxedges = m.secondlayer.edges(:,[1 2]);
            vxedgepos = reshape( m.secondlayer.cell3dcoords( vxedges', : ), 2, [], 3 );
            vxedgevec = squeeze( vxedgepos(2,:,:) - vxedgepos(1,:,:) );
            edgedist = sqrt( sum( vxedgevec.^2, 2 ) );
            s.abssize = s.relsize * sum(edgedist) / length(edgedist);
        else
            s.relsize = 0;
        end

        if s.abssize <= 0
            return;
        end
        amount = s.abssize;
    else
        if isempty( s.amounttype )
            return;
        end
        switch s.amounttype
            case 'tissue'
                if ischar( s.amount )
                    mgenindex = FindMorphogenIndex( m, s.amount );
                    if mgenindex==0
                        return;
                    end
                    s.amount = m.morphogens(:,mgenindex);
                elseif numel(s.amount)==1
                    s.amount = s.amount + zeros( size(m.morphogens,1), 1 );
                end
                amount = perFEVertexToPerCellVertex( m, s.amount );
            case 'cellular'
                % NOT SUPPORTED YET
                return;
            case 'cellvertex'
                if numel(s.amount)==1
                    amount = s.amount + zeros( length(m.secondlayer.vxFEMcell), 1 );
                else
                    amount = s.amount;
                end
            otherwise
                % Error.
                fprintf( 1, '%s: ''amount'' was specified without ''amounttype''.  Command ignored.\n', mfilename() );
                return;
        end
        if strcmp( s.amountmode, 'reldist' )
            % The amount is to be understood as a proportion of the
            % distance of each IC vertex from the centroid of its IC space.
            
            [numcycles,cycles,cycleends] = countICspaces( m );
%             % Find all edges that border an IC space.
%             icEdges = m.secondlayer.edges(:,4)==-1;
%             icEdgeEnds = m.secondlayer.edges(icEdges,[1 2]);
%             
%             % Group them into the cycles that enclose each space.
%             cycles = findCycles( icEdgeEnds );
%             
%             % cycles lists the vertexes of all the cycles, each cycle
%             % terminated by a zero.  Find where each cycle begins and ends.
%             cycleends = find(cycles==0);
%             numcycles = length(cycleends);
            cyclestarts = [1 cycleends(1:(end-1))+1];
            cycleends = cycleends-1;
            
            % Calculate the centroid of the vertexes of each IC space, and
            % the vector from the centroid to each vertex of that space.
            vxdisps = zeros( length(m.secondlayer.vxFEMcell), 3 );
            for i=1:numcycles
                s = cyclestarts(i);
                e = cycleends(i);
                cyclelength = e-s+1;
                if cyclelength >= 3
                    vxindexes = cycles(s:e);
                    vxpos =  m.secondlayer.cell3dcoords( vxindexes, : );
                    centroid = polyCentroid( vxpos );
                    % centroid = sum(vxpos,1)/cyclelength;
                    vxdisps(vxindexes,:) = vxpos - repmat( centroid, cyclelength, 1 );
                end
            end
            
            % Calculate the lengths of all of the vectors.
            vxdists = sqrt( sum( vxdisps.^2, 2 ) );
            
            % vxdists is defined for all cell vertexes, and is zero for
            % those not belonging to any IC space.
            
            % Scale the amounts by the distances.
            amount = amount .* vxdists;
        end
    end
    
    if (length(amount) ~= 1) && (length(amount) ~= length(m.secondlayer.vxFEMcell))
        fprintf( 1, '%s: Wrong amount of data specified by ''amount'' and ''amounttype'' (%s) options.  %d values found, %d expected.  Command ignored.\n', ...
            mfilename(), s.amounttype, length(amount), length(m.secondlayer.vxFEMcell) );
        return;
    end
    vxs = any( m.secondlayer.edges(:,[3 4]) < 0, 2 );
    vxs = unique(m.secondlayer.edges(vxs,[1 2]));
    if length(amount) ~= 1
        amount = amount(vxs);
    end
    % vxs is all vertexes adjoining an air space.
    m = makeSpaceAtBioVertexes( m, vxs, amount, m.globalProps.bioMinEdgeLength, m.globalProps.bioSpacePullInRatio );
end
