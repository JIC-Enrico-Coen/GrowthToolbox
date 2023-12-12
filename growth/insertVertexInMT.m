function [mt,vx,ok] = insertVertexInMT( m, mt, segindex, bcs )
%mt = insertVertexInMT( mt, segindex, bcs )
%   Insert a new vertex into a microtubule on the given segment, at the
%   point having the given barycentric coordinates.
%
%   mt will be a microtubule track such as is contained in
%   m.tubules.tracks.
%
%   vx will be the vertex index of the vertex. If no new vertex has to be
%   created, then vx will equal segindex, otherwise it will be segindex+1.
%   If anything goes wrong in the calculation, vx is returned as 0 and mt
%   is not changed.
%
%   ok will be false if something goes wrong. This indicates an error in
%   the code.

    vx = 0;
    ok = true;
    bcs = roundBarycoords( bcs );
    if bcs(1) == 0
        bcs = [1 0];
        segindex = segindex+1;
    end
    

    % Sanity checks: if the point is at either end of the mt, do
    % nothing.
    if segindex >= length( mt.vxcellindex )
        vx = length( mt.vxcellindex );
        return;
    end

    if (segindex <= 0) || ((segindex==1) && (bcs(1)==1))
        vx = 1;
        return;
    end
    
    if bcs(1) == 1
        % No new vertex. Nothing to do but return the vertex index.
        vx = segindex;
        return;
    end
    
    % The vertex is to be inserted into the interior of an existing segment.
    
    % We need to take into account that the two ends of the segment
    % might not be assigned to the same finite element.
    newvxglobalcoords = bcs * mt.globalcoords( [segindex, segindex+1], : );
    if mt.vxcellindex( segindex ) == mt.vxcellindex( segindex+1 )
        segtype = 'SAME';
        newvxcellindex = mt.vxcellindex( segindex );
        bc1 = mt.barycoords( segindex, : );
        bc2 = mt.barycoords( segindex+1, : );
    elseif all( mt.barycoords(segindex,:) > 0 )
        segtype = 'FIRST';
        newvxcellindex = mt.vxcellindex( segindex );
        bc1 = mt.barycoords( segindex, : );
        bc2 = transferBC( m, mt.vxcellindex( segindex+1 ), mt.barycoords( segindex+1, : ), newvxcellindex );
        if isempty(bc2)
            % This should not happen.
            fprintf( 1, '%s: segtype = ''FIRST'': transferBC failed, bc2 is empty.\n', mfilename() );
            ok = false;
        end
    elseif all( mt.barycoords(segindex+1,:) > 0 )
        segtype = 'SECOND';
        newvxcellindex = mt.vxcellindex( segindex+1 );
        bc1 = transferBC( m, mt.vxcellindex( segindex ), mt.barycoords( segindex, : ), newvxcellindex );
        bc2 = mt.barycoords( segindex+1, : );
        if isempty(bc1)
            % This should not happen.
            fprintf( 1, '%s: segtype = ''SECOND'': transferBC failed, bc1 is empty.\n', mfilename() );
            ok = false;
        end
    else
        segtype = 'BOTH';
%         % Test code, to be compared with the use of transferBC below.
%         [newvxcellindex, bc1, bc2] = referToSameTriangle( m, ...
%             mt.vxcellindex( segindex ), mt.barycoords( segindex, : ),...
%             mt.vxcellindex( segindex+1 ), mt.barycoords( segindex+1, : ) );

        % Assume that the vertexes are referenced to their following
        % element.
        newvxcellindex = mt.vxcellindex( segindex );
        bc1 = mt.barycoords( segindex, : );
        bc2 = transferBC( m, mt.vxcellindex( segindex+1 ), mt.barycoords( segindex+1, : ), newvxcellindex );
        if isempty(bc2)
            % This should not happen.
            fprintf( 1, '%s: segtype = ''BOTH'': transferBC failed, bc2 is empty.\n', mfilename() );
            ok = false;
        end
    end
    
    if ~ok
        return;
    end
    
    % We now have the two points on either side of the new point. But the
    % new point might be very close to either of them, in which case we
    % want to return the closest instead of making a new point.
    
    newvxbcs = roundBarycoords( bcs * [bc1; bc2] );
    dbc1 = newvxbcs-bc1;
    dbc2 = newvxbcs-bc2;
    nd1 = sum(abs(dbc1));
    nd2 = sum(abs(dbc2));
    nd = min([nd1,nd2]);
    TOLERANCE = 1e-4;
    if nd < TOLERANCE
        if nd1 <= nd2
            vx = segindex;
        else
            vx = segindex+1;
        end
        return;
    end

    if ok
        mt = updateSeverancePointsForInsertion( mt, segindex );
        mt.vxcellindex = [ mt.vxcellindex( 1:segindex ) newvxcellindex mt.vxcellindex( (segindex+1):end ) ];
        mt.iscrossovervx = [ reshape( mt.iscrossovervx( 1:segindex ), 1, [] ), false, reshape( mt.iscrossovervx( (segindex+1):end ), 1, [] ) ];
        mt.segcellindex = [  mt.segcellindex( 1:segindex ) newvxcellindex mt.segcellindex( (segindex+1):end ) ];
        mt.barycoords = [ mt.barycoords( 1:segindex, : ); newvxbcs; mt.barycoords( (segindex+1):end, : ) ];
        mt.globalcoords = [ mt.globalcoords( 1:segindex, : ); newvxglobalcoords; mt.globalcoords( (segindex+1):end, : ) ];
        cutseglength = mt.segmentlengths(segindex);
        mt.segmentlengths = [ mt.segmentlengths( 1:(segindex-1) ) cutseglength*bcs([2 1]) mt.segmentlengths( (segindex+1):end ) ];
        if ~checkZeroBcsInStreamline( mt )
            xxxx = 1;
        end
        vx = segindex+1;
    end

    [oks,errfields] = validStreamline( m, mt );
    if any( ~oks )
        xxxx = 1;
    end
end
