function s = shrinkStreamlineBy( m, s, amount, fromhead )
%s = shrinkStreamline( m, s, amount, fromhead )
%   Cut off a length AMOUNT from the tubule S, from the head if FROMHEAD is
%   true, otherwise from the tail.
%
%   If the amount is at least the total length of the tubule (to within a
%   certain tolerance) the whole streamline is zeroed. (It will be removed
%   from M later.)

    if amount <= 0
        return;
    end
    
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

    TOLERANCE = 1e-5;
    if amount <= TOLERANCE
        return;
    end

    if amount >= sum( s.segmentlengths ) - TOLERANCE
        s = zerostreamline( s );
        return;
    end
    if fromhead
        cumlengths = cumsum( s.segmentlengths(end:-1:1) );
    else
        cumlengths = cumsum( s.segmentlengths );
    end
    segindex = find( cumlengths > amount, 1 );
    delta = cumlengths(segindex) - amount;
    if fromhead
        segindex = length(s.segmentlengths) + 1 - segindex;
    end
    fractionToKeep = delta/s.segmentlengths(segindex);
    ss = shrinkStreamlineTo( m, s, segindex, fractionToKeep, fromhead );
    
    
    
    oldlength = sum( s.segmentlengths );
    totlen = 0;
    if fromhead
        segi = length(s.segmentlengths);
        segi_stop = 0;
        segi_incr = -1;
    else
        segi = 1;
        segi_stop = length(s.vxcellindex)+1;
        segi_incr = 1;
    end
    while segi ~= segi_stop
        totlen = totlen + s.segmentlengths(segi);
        if totlen >= amount - TOLERANCE
            break;
        end
        segi = segi + segi_incr;
    end
    if segi==segi_stop
        BREAKPOINT( '%s: streamline is shorter than amount to shrink, but this was not initially detected.\n', mfilename() );
    end
    excess = totlen - amount;
    if abs(excess) < TOLERANCE
        excess = 0;
    end
    vxstart = segi;
    vxend = segi+1;
    fractionToKeep = trimnumber( 0, excess/s.segmentlengths(segi), 1, TOLERANCE );
    if fromhead
        if fractionToKeep==1
            vxstart = segi+1;
            vxend = segi+2;
            fractionToKeep = 0;
            if vxend > length(s.vxcellindex)
                vxend = length(s.vxcellindex);
                xxxx = 1;
            end
        end
        if fractionToKeep > 0
            % Move the segend point to be that fraction of the way from the
            % segstart to the segend point.
            ci1 = s.vxcellindex(vxstart);
            bc1 = s.barycoords(vxstart,:);
            ci2 = s.vxcellindex(vxend);
            bc2 = s.barycoords(vxend,:);
            [ci, bc1, bc2] = referToSameTriangle( m, ci1, bc1, ci2, bc2 );
            s.barycoords( vxend, : ) = bc1*fractionToKeep + bc2*(1-fractionToKeep);
            if ~checkZeroBcsInStreamline( s )
                xxxx = 1;
            end
            if all(s.directionglobal==0)
                xxxx = 1;
            end
            s.vxcellindex(vxend) = ci;
            s.segcellindex(vxend) = ci;
            s.globalcoords( vxend, : ) = streamlineGlobalPos( m, s, vxend );
            s.segmentlengths(segi) = fractionToKeep * s.segmentlengths(segi);
        end
        if fractionToKeep == 0
            discardvx = vxend;
        else
            discardvx = vxend+1;
        end
        if ~isempty( s.status.severance )
            sevvxs = [s.status.severance.vertex];
            if fractionToKeep > 0
                dropped = sevvxs >= discardvx;
            else
                dropped = sevvxs >= discardvx-1;
            end
            s.status.severance( dropped ) = [];
        end
%         s = updateSeverancePointsForDeletion( s, [discardvx length(s.vxcellindex)] );
        [s.directionbc,s.directionglobal] = streamlineSegmentDirection( m, s, segi );
        s.barycoords( discardvx:end, : ) = [];
        s.globalcoords( discardvx:end, : ) = [];
        s.vxcellindex( discardvx:end ) = [];
        s.iscrossovervx( discardvx:end ) = [];
        s.segcellindex( discardvx:end ) = [];
        s.segmentlengths( (discardvx-1):end ) = [];
        if ~checkZeroBcsInStreamline( s )
            xxxx = 1;
        end
    else
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
            s.segmentlengths(segi) = fractionToKeep * s.segmentlengths(segi);
        end
        if ~isempty( s.status.severance )
            sevvxs = [s.status.severance.vertex];
            if fractionToKeep == 0
                dropped = sevvxs <= discardvx+1;
            else
                dropped = sevvxs <= discardvx;
            end
%             if fractionToKeep < 1
%                 sevbcs = [s.status.severance.bc];
%                 initalvxs = sevvxs == vxstart;
%                 adjusted = initalvxs & (1-sevbcs < fractionToKeep);
%                 dropped( initalvxs & ~adjusted ) = true;
%                 for ii = find(adjusted)
%                     s.status.severance(ii).bc = 1 - (1 - s.status.severance(ii).bc) / fractionToKeep;
%                 end
%             end
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
    
    newlength = sum( s.segmentlengths );
    shrinktest = oldlength - newlength - amount;
    if shrinktest > 1e-5
        BREAKPOINT( 'shrinktest fail %g\n', shrinktest );
    end
%     if ~validStreamline( m, s )
%         BREAKPOINT( 'Invalid streamline.\n' );
%     end
    if ~compareStructs(s,ss)
        xxxx = 1;
    end
end

