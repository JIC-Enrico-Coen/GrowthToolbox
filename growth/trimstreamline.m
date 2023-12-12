function m = trimstreamline( m, si, head, amount )
%m = trimstreamline( m, si, head, amount )
%   Trim AMOUNT from streamline number si of m. If head is true, trim the
%   head, otherwise the tail.

    % Accumulate lengths of segments from the appropriate end.
    % If this uses up the whole streamline, make the streamline empty.
    % Otherwise, split the segment where the amount ended.
    % If trimming from the head, recompute directionbc and directionglobal.
    
    s = m.tubules.tracks(si);
    streamlineLength = length( s.vxcellindex );
    
    if isemptystreamline( s )
        % Streamline is empty.
        return;
    end
    
    if amount <= 0
        % Nothing to trim.
        return;
    end
    
    if head
        start = streamlineLength;
        finish = 1;
        increment = -1;
    else
        start = 1;
        finish = streamlineLength;
        increment = 1;
    end
    
    currentindex = start;
    accumulatedLength = 0;
    currentpoint = getStreamlinePoint( m, m.tubules.tracks(si), currentindex );
    while currentindex ~= finish
        previousindex = currentindex;
        previouspoint = currentpoint;
        currentindex = currentindex + increment;
        currentpoint = getStreamlinePoint( m, m.tubules.tracks(si), currentindex );
        segmentlength = sqrt( sum( (currentpoint - previouspoint).^2, 2 ) );
        accumulatedLength = accumulatedLength + segmentlength;
        if accumulatedLength >= amount
            if accumulatedLength == amount
                if currentindex == finish
                    % Streamline has vanished.
                    s.barycoords = [];
                    s.vxcellindex = [];
                    s.iscrossovervx = [];
                elseif head
                    s.barycoords( (currentindex+1):end, : ) = [];
                    s.vxcellindex( (currentindex+1):end ) = [];
                    s.iscrossovervx( (currentindex+1):end ) = [];
                else
                    s.barycoords( currentindex-1, : ) = [];
                    s.vxcellindex( currentindex-1 ) = [];
                    s.iscrossovervx( (currentindex+1):end ) = [];
                end
            else
                % currentpoint and previouspoint need to be referred to the
                % same element. If at least one is an interior point, the
                % associated element is the one. If both points are already
                % referred to the same element, that is the one. But if
                % both are on edges or vertexes and are referred to
                % different elements, which is the correct one? Our current
                % method of extrapolating a streamline places whichever
                % point is earlier on the appropriate element to use here.
                % So we will use that method for the moment.
                
                currentci = s.vxcellindex( currentindex );
                currentbc = s.barycoords( currentindex, : );
                previousci = s.vxcellindex( previousindex );
                previousbc = s.barycoords( previousindex, : );
                if currentci==previousci
                    cuttingpointci = currentci;
                elseif all( currentbc>0 )
                    cuttingpointci = currentci;
                elseif all( previousbc>0 )
                    cuttingpointci = previousci;
                elseif head
                    cuttingpointci = currentci;
                else
                    cuttingpointci = previousci;
                end
                if cuttingpointci ~= currentci
                    % Translate currentci and currentbc to cuttingpointci.
                    currentbc = transferBC( m, currentci, currentbc, cuttingpointci );
%                     currentci = cuttingpointci;
                end
                if cuttingpointci ~= previousci
                    % Translate previousci and previousbc to chosenci.
                    previousbc = transferBC( m, previousci, previousbc, cuttingpointci );
%                     previousci = cuttingpointci;
                end
                % currentbc and previousbc now both relate to cuttingpointci.
                
                fractionToCut = (accumulatedLength - amount)/segmentlength;
                cuttingpointbc = currentbc * (1 - fractionToCut) + previousbc * fractionToCut;
                
                if head
                    s.directionglobal = previouspoint - currentpoint;
                    s.directionglobal = s.directionglobal/norm(s.directionglobal);
                    s.directionbc = vec2bc( s.directionglobal, m.nodes( m.tricellvxs( cuttingpointci, : ), : ) );
                end
                
                antepreviousindex = previousindex - increment;
                
                s.barycoords( antepreviousindex:end, : ) = [];
                s.vxcellindex( antepreviousindex:end ) = [];
                s.iscrossovervx( antepreviousindex:end ) = [];
                s.barycoords( previousindex, : ) = cuttingpointbc;
                s.vxcellindex( previousindex ) = cuttingpointci;
                if ~checkZeroBcsInStreamline( s )
                    xxxx = 1;
                end
            end
            break;
        end
    end
    
    m.tubules.tracks(si) = s;
end

function newbc = transferBC( m, ci, bc, newci )
% bc is the barycentric coordinates of a point in element ci. This point is
% assumed to also lie in the element newci. The result is the barycentric
% coordinates of the point with respect to newci.

% If ci is not equal to newci, then bc must have either one or two members
% equal to zero, corresponding to those vertexes of ci that do not belong
% to newci.

    if ci==newci
        newbc = bc;
    else
        numzeros = sum(bc==0);
        switch numzeros
            case 1
                % Edge
                [cj,bcj] = transferEdgeBC( m, ci, bc );
                if cj ~= newci
                    BREAKPOINT( 'transferBC: point %d [%.3f %.3f %.3f] should transfer to %d, actually transferrred to %d.\n', ...
                        ci, bc, newci, cj ); 
                else
                    newbc = bcj;
                end
            case 2
                % Vertex
                bci = find( bc > 0, 1 );
                vi = m.tricellvxs( ci, bci );
                newcvi = find( m.tricellvxs( newci, : )==vi, 1 );
                if isempty( newcvi )
                    BREAKPOINT( 'transferBC: element %d does not meet element %d at vertex %d.\n', ci, newci, vi ); 
                else
                    newbc = [0 0 0];
                    newbc( newcvi ) = 1;
                end
            otherwise
                BREAKPOINT( 'Expected one or two zero bcs, found %d.\n', numzeros );
        end
    end
end

function streamlinepoint = getStreamlinePoint( m, s, index )
    bc = s.barycoords( index, : );
    ci = s.vxcellindex( index );
    streamlinepoint = bc * m.nodes( m.tricellvxs( ci, : ), : );
end
