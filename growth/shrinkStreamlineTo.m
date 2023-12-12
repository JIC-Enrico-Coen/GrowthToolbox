function s = shrinkStreamlineTo( m, s, segindex, fractionToKeep, deletehead )
%s = shrinkStreamlineTo( m, s, segindex, segbc, fromhead )
%   Cut the streamline at the given segment, and the given position within
%   the segment. Discard the head portion if fromhead is true, otherwise
%   the tail portion.
%
%   If this leaves nothing of the streamline (to within a certain tolerance)
%   the whole streamline is zeroed. (It will be removed from M later.)

    if all(s.directionglobal==0)
        xxxx = 1;
    end
    
    if isnumeric(s)
        s = m.tubules.tracks(s);
    end
    if ~validStreamline( m, s )
%         fprintf( 'Invalid streamline.\n' );
%         BREAKPOINT( 'Invalid streamline.\n' );
    end
    
    if ~checkZeroBcsInStreamline( s )
        xxxx = 1;
    end
    if isempty(segindex)
        return;
    end
    
    if deletehead
        segbc = [ 1-fractionToKeep, fractionToKeep ];
    else
        segbc = [ fractionToKeep, 1-fractionToKeep ];
    end

    TOLERANCE = 1e-5;
    segbc = roundBarycoords( segbc, TOLERANCE );
    if segbc(1) == 0
        segbc = [1 0];
        segindex = segindex+1;
        if segindex >= length(s.segcellindex)
            % Trying to trim nothing. No more to do.
            return;
        end
    end
    
    deleteWholeStreamlineFromTail = (~deletehead) && (segindex >= length( s.vxcellindex ));
    deleteWholeStreamlineFromHead = deletehead && ((segindex < 1) || ((segindex==1) && (segbc(1)==1)));
    if deleteWholeStreamlineFromTail || deleteWholeStreamlineFromHead
        s = zerostreamline( s );
        return;
    end
    
    oldlength = sum( s.segmentlengths );
    vxstart = segindex;
    vxend = segindex+1;
    if deletehead
        if segbc(2) == 0
            discardvx = vxend;
        else
            discardvx = vxend+1;
            % Move the segend point to be that fraction of the way from the
            % segstart to the segend point.
            ci1 = s.vxcellindex(vxstart);
            bc1 = s.barycoords(vxstart,:);
            ci2 = s.vxcellindex(vxend);
            bc2 = s.barycoords(vxend,:);
            [ci, bc1, bc2] = referToSameTriangle( m, ci1, bc1, ci2, bc2 );
            s.barycoords( vxend, : ) = segbc * [bc1; bc2];
            s_barycoords = bc1*fractionToKeep + bc2*(1-fractionToKeep);
            if ~checkZeroBcsInStreamline( s )
                xxxx = 1;
            end
            if all(s.directionglobal==0)
                xxxx = 1;
            end
            s.vxcellindex(vxend) = ci;
            s.segcellindex(vxend) = ci;
            s.globalcoords( vxend, : ) = streamlineGlobalPos( m, s, vxend );
            s.segmentlengths(segindex) = segbc(2) * s.segmentlengths(segindex);
        end
        if ~isempty( s.status.severance )
            sevvxs = [s.status.severance.vertex];
            if segbc(2) > 0
                dropped = sevvxs >= discardvx;
            else
                dropped = sevvxs >= discardvx-1;
            end
            s.status.severance( dropped ) = [];
        end
        
        
        
%         s = updateSeverancePointsForDeletion( s, [discardvx length(s.vxcellindex)] );
        if ~checkZeroBcsInStreamline( s )
            xxxx = 1;
        end
        [newdbc,newdg] = streamlineSegmentDirection( m, s, segindex );
        if abs( sum(newdbc) ) > 1e-3
            xxxx = 1;
        end
        s.directionbc = newdbc;
        s.directionglobal = newdg;
        s.barycoords( discardvx:end, : ) = [];
        s.globalcoords( discardvx:end, : ) = [];
        s.vxcellindex( discardvx:end ) = [];
        s.iscrossovervx( discardvx:end ) = [];
        s.segcellindex( discardvx:end ) = [];
        s.segmentlengths( (discardvx-1):end ) = [];
        if ~checkZeroBcsInStreamline( s )
            xxxx = 1;
        end
%         if ~validStreamline( m, s )
%             BREAKPOINT( 'Invalid streamline.\n' );
%         end
    else
        fractionToKeep = segbc(1);  % trimnumber( 0, excess/s.segmentlengths(segindex), 1, TOLERANCE );
%         if ~validStreamline( m, s )
%             BREAKPOINT( 'Invalid streamline.\n' );
%         end
        if fractionToKeep == 0
            vxstart = vxstart+1;
            vxend = vxend+1;
            fractionToKeep = 1;
        end
        discardvx = vxstart-1;
        if fractionToKeep < 1
            % Move the segstart point to be that fraction of the way from
            % the segstart to the segend point.
            if vxend > length(s.vxcellindex)
                BREAKPOINT( 'Out of cellindex bounds %d > %d\n', vxstart, length(s.vxcellindex) );
            end
            ci1 = s.vxcellindex(vxstart);
            bc1 = s.barycoords(vxstart,:);
            ci2 = s.vxcellindex(vxend);
            bc2 = s.barycoords(vxend,:);
            [ci, bc1, bc2] = referToSameTriangle( m, ci1, roundBarycoords(bc1), ci2, roundBarycoords(bc2) );
            if isempty(ci)
                fprintf( 1, '%s: referToSameTriangle fails.\n', mfilename() );
                xxxx = 1;
            end
            s.barycoords( vxstart, : ) = bc1*fractionToKeep + bc2*(1-fractionToKeep);
            if ~checkZeroBcsInStreamline( s )
                xxxx = 1;
            end
            s.vxcellindex(vxstart) = ci;
            s.segcellindex(vxstart) = ci;
            s.globalcoords( vxstart, : ) = streamlineGlobalPos( m, s, vxstart );
            s.segmentlengths(segindex) = fractionToKeep * s.segmentlengths(segindex);
        end
        if ~isempty( s.status.severance )
            sevvxs = [s.status.severance.vertex];
            if fractionToKeep == 0
                dropped = sevvxs <= discardvx+1;
            else
                dropped = sevvxs <= discardvx;
            end
            s.status.severance( dropped ) = [];
            for ii=1:length(s.status.severance)
                s.status.severance(ii).vertex = s.status.severance(ii).vertex - discardvx;
            end
        end
%         s = updateSeverancePointsForDeletion( s, [1 discardvx] );
        s.barycoords( 1:discardvx, : ) = [];
        s.globalcoords( 1:discardvx, : ) = [];
        s.vxcellindex( 1:discardvx ) = [];
        s.iscrossovervx( 1:discardvx ) = [];
        s.segcellindex( 1:discardvx ) = [];
        s.segmentlengths( 1:discardvx ) = [];
        if discardvx > 0
            xxxx = 1;
        end
%         if ~validStreamline( m, s )
%             BREAKPOINT( 'Invalid streamline.\n' );
%         end
    end
    
    if all(s.directionglobal==0)
        xxxx = 1;
    end
    
    if ~validStreamline( m, s )
        BREAKPOINT( 'Invalid streamline.\n' );
        xxxx = 1;
    end
end

