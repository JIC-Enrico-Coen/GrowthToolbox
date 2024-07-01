function c = directionalCurvature( m, ci, bcs, dirglobal, interpolationMode )
%c = directionalCurvature( m, ci, bcs, dirglobal, interpolationMode )
%   Given a curvature field in m.auxdata.curvatures, a surface point
%   specified by an element ci and barycentric coordinates bcs, and a unit
%   tangent vector dirglobal, calculate the curvature along that direction
%   at that point.

    if nargin < 5
        interpolationMode = 'mid';
    end
    
    numitems = max( [ length(ci), size(bcs,1), size(dirglobal,1) ] );
    if length(ci)==1
        ci = ci + zeros(numitems,1);
    end
    if size(bcs,1)==1
        bcs = repmat( bcs, numitems, 1 );
    end
    if size(dirglobal,1)==1
        dirglobal = repmat( dirglobal, numitems, 1 );
    end
    c = zeros(numitems,1);
    c1 = zeros(numitems,1);

    if ~isfield( m, 'auxdata' ) || ~isfield( m.auxdata, 'curvatures' )
        return;
    end
    
    for i=1:numitems
        tricurvatures = m.auxdata.curvatures( :, :, m.tricellvxs( ci(i), : ) );
        switch interpolationMode
            case 'mid'
                selectedtraces = [1 2 3];
            case 'min'
                traces = pagetrace( tricurvatures );
                mintrace = min(traces);
                selectedtraces = abs(traces-mintrace) < 1e-5;
%                 pointcurvature = tricurvatures( :, :, whichtrace );
            case 'max'
                traces = pagetrace( tricurvatures );
                maxtrace = max(traces);
                selectedtraces = abs(traces-maxtrace) < 1e-5;
%                 [~,whichtrace] = max(traces);
%                 pointcurvature = tricurvatures( :, :, whichtrace );
        end
        selectedbcs = shiftdim( bcs(i,selectedtraces), -1 );
        if all(selectedbcs==0)
            c(i) = 0;
        else
            selectedbcs = selectedbcs / sum(selectedbcs);
            pointcurvature = sum( tricurvatures(:,:,selectedtraces) .* selectedbcs, 3 );
            if pointcurvature ~= 0
                xxxx = 1;
            end
            c(i) = dirglobal(i,:) * pointcurvature * dirglobal(i,:)';
            
%             % Alternative calculation, depending on knowledge of the
%             % specific geometry of the mesh.
%             RADIUS_OF_CURVATURE = m.meshparams.edgeradius(1);
%             if all( pagetrace(tricurvatures) > 2 - 1e-5 )
%                 c1(i) = RADIUS_OF_CURVATURE;
%             elseif all(pointcurvature(:)==0)
%                 c1(i) = 0;
%             elseif all( pagetrace(tricurvatures(:,:,selectedtraces)) < 1e-5 )
%                 c1(i) = 0;
%             else
%                 % We are in an edge region. Find out which planes the
%                 % relevant vertexes are.
%                 civxs = m.tricellvxs(ci(i),:);
%                 ciplanes = m.auxdata.planes(civxs,:);
%                 midplanes = (ciplanes > m.auxdata.numcurvedplanes) & (ciplanes < m.auxdata.numplanes-m.auxdata.numcurvedplanes+1);
%                 edgeaxis = find( all(midplanes,1) );
%                 if length( edgeaxis ) ~= 1
%                     c1(i) = NaN;
%                     xxxx = 1;
%                 else
%                 % c(i) should be 1/arccos(theta^2), where theta is the
%                 % angle between dirglobal and the direction of maximum
%                 % curvature.
%                     stheta = dirglobal(i,edgeaxis);
%                     cthetasq = 1 - stheta.^2;
%                     c1(i) = RADIUS_OF_CURVATURE * cthetasq;
%                     xxxx = 1;
%                 end
%             end
        end
    end
    for i=1:numitems
        RADIUS_OF_CURVATURE = m.meshparams.edgeradius(1);
        civxs = m.tricellvxs(ci(i),:);
        ax = whichaxis( m, civxs );
        switch ax
            case 0
                % We are in a corner region. The curvature of the tubule is
                % independent of direction.
                c1(i) = 1/RADIUS_OF_CURVATURE;
                xxxx = 1;
            case -1
                % We are in a flat face. The curvature is zero.
                c1(i) = 0;
                xxxx = 1;
            otherwise
                % We are in an edge region. The corresponding element of
                % dirglobal is the cos of the angle of dirglobal with the
                % edge direction, and therefore is the sin of the angle of
                % dirglobal with the edge perpendicular. We need the cosine
                % squared of the latter angle.
                stheta = dirglobal(i,ax);
                cthetasq = 1 - stheta.^2;
                c1(i) = cthetasq/RADIUS_OF_CURVATURE;
                xxxx = 1;
        end
    end
    
    NEWMETHOD = true;
    if NEWMETHOD
        c = c1;
    end
end

function ax = whichaxis( m, vxs )
    vxplanes = m.auxdata.planes(vxs,:);
    nearend = (vxplanes <= m.auxdata.numcurvedplanes) | (vxplanes > m.auxdata.numplanes-m.auxdata.numcurvedplanes);
    ax = find( ~all( nearend, 1 ) );
    switch length(ax)
        case 3
            % Should not happen.
            ax = -1;
            xxxx = 1;
        case 2
            % The element is not in an edge or corner region.
            ax = -1;
        case 1
            % The element is in an edge region and not a corner region.
            % ax identifies the axis parallel to that edge.
        case 0
            % The element is in a corner region.
            % The curvature is therefore independent of direction.
    end
    if isempty( ax )
        ax = 0;
    else
    end
end
