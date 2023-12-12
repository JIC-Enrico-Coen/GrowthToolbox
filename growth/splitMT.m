function [mtrear,mtfront] = splitMT( m, mt, vxindex, catrearhead, catfronttail )
%[mtrear,mtfront] = splitMT( m, mt, vxindex, catrearhead, catfronttail )
%   Split the given microtubule at the given vertex into a rear part and a
%   front part.
%
%   mt will be a microtubule track such as is contained in
%   m.tubules.tracks.
%
%   vxindex is a vertex to split it at.
%
%   catrearhead is a boolean specifying whether the head of the rear tubule
%   catastrophizes.
%
%   catfronttail is a boolean specifying whether the tail of the front
%   tubule catastrophizes.
%
%   mtrear will have the same id as mt. mtfront will be given id zero,
%   and must be given a new id by the code this is called from. That 
%   code will also have to calculate directionbc and directionglobal for
%   mtrear, and add mtfront to m.tubules.

    mtrear = mt;
    mtfront = [];
    
    % Sanity check: if the split point is at or beyond either end of the
    % mt, do nothing.
    if (vxindex <= 1) || (vxindex >= length( mt.vxcellindex ))
        return;
    end

    mtfront = mt;
    mtfront.id = 0; % The new mt has no id.
    
    if catrearhead
        mtrear.status.head = -1;
    else
        mtrear.status.head = 1;
    end
    mtrear.status.shrinktail = 1;
    mtrear.status.shrinktime = 0;
    
    mtfront.status.catshrinktail = catfronttail;
    
    % Pending events are referenced to vertexes of the original tubule,
    % indexed from the tail end forwards. Each event must be allocated to
    % the rear or front section, and in the front section they must be
    % reindexed.
    mtrear = updateSeverancePointsForDeletion( mtrear, [vxindex+1 length(mtrear.vxcellindex)] );
    mtfront = updateSeverancePointsForDeletion( mtfront, [1 vxindex-1] );

    % Divide the vertexes and everything else between the two tubules.
    mtfront.vxcellindex = mt.vxcellindex( vxindex:end );
    mtrear.vxcellindex = mt.vxcellindex( 1:vxindex );
    
    mtfront.iscrossovervx = mt.iscrossovervx( vxindex:end );
    if ~isempty( mtfront.iscrossovervx )
        mtfront.iscrossovervx( [1, end] ) = false;
    end
    mtrear.iscrossovervx = mt.iscrossovervx( 1:vxindex );
    if ~isempty( mtrear.iscrossovervx )
        mtrear.iscrossovervx( [1, end] ) = false;
    end
    
    mtfront.segcellindex = mt.segcellindex( vxindex:end );
    mtrear.segcellindex = mt.segcellindex( 1:vxindex );
    
    mtfront.barycoords = mt.barycoords( vxindex:end, : );
    mtrear.barycoords = mt.barycoords( 1:vxindex, : );
    
    mtfront.globalcoords = mt.globalcoords( vxindex:end, : );
    mtrear.globalcoords = mt.globalcoords( 1:vxindex, : );
    
    mtfront.segmentlengths = mt.segmentlengths( vxindex:end );
    mtrear.segmentlengths = mt.segmentlengths( 1:(vxindex-1) );
    
    % Calculate the direction of the rear tubule.
    [mtrear.directionbc,mtrear.directionglobal] = streamlineSegmentDirection( m, mt, vxindex-1 );
    
    if ~checkZeroBcsInStreamline( mtrear )
        xxxx = 1;
    end

    [oks,errfields] = validStreamline( m, [mtfront mtrear] );
    if any( ~oks )
        xxxx = 1;
    end
end
