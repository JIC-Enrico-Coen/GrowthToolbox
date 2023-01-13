function [mttail,mthead] = splitMT( m, mt, vxindex, cattail, cathead )
%[mt1,mt2] = splitMT( mt, segindex, bcs )
%   Split the given microtubule at the given vertex.
%
%   mt will be a microtubule track such as is contained in
%   m.tubules.tracks.
%
%   vxindex is a vertex to split it at.
%
%   cattail and cathead are booleans specifying whether the head of the
%   tail end, and the tail of the head end, catastrophize.
%
%   mttail will have the same id as mt. mthead will be given id zero,
%   and must be given a new id by the code this is called from. That 
%   code will also have to calculate directionbc and directionglobal for
%   mttail, and add mthead to m.tubules.

    mttail = mt;
    mthead = [];
    
    % Sanity check: if the split point is at or beyond either end of the
    % mt, do nothing.
    if (vxindex <= 1) || (vxindex >= length( mt.vxcellindex ))
        return;
    end

    mthead = mt;
    mthead.id = 0; % The new mt has no id.
    
    if cattail
        mttail.status.head = -1;
    else
        mttail.status.head = 1;
    end
    mttail.status.shrinktail = 1;
    mttail.status.shrinktime = 0;
    
    mthead.status.catshrinktail = cathead;
    
    mttail = updateSeverancePointsForDeletion( mttail, [vxindex+1 length(mttail.vxcellindex)] );
    mthead = updateSeverancePointsForDeletion( mthead, [1 vxindex-1] );

    mthead.vxcellindex = mt.vxcellindex( vxindex:end );
    mttail.vxcellindex = mt.vxcellindex( 1:vxindex );
    
    mthead.segcellindex = mt.segcellindex( vxindex:end );
    mttail.segcellindex = mt.segcellindex( 1:vxindex );
    
    mthead.barycoords = mt.barycoords( vxindex:end, : );
    mttail.barycoords = mt.barycoords( 1:vxindex, : );
    
    mthead.globalcoords = mt.globalcoords( vxindex:end, : );
    mttail.globalcoords = mt.globalcoords( 1:vxindex, : );
    
    mthead.segmentlengths = mt.segmentlengths( vxindex:end );
    mttail.segmentlengths = mt.segmentlengths( 1:(vxindex-1) );
    
    [mttail.directionbc,mttail.directionglobal] = streamlineSegmentDirection( m, mt, vxindex-1 );
    
    if ~checkZeroBcsInStreamline( mttail )
        xxxx = 1;
    end

    [oks,errfields] = validStreamline( m, [mthead mttail] );
    if any( ~oks )
        xxxx = 1;
    end

%                  id: 2
%         vxcellindex: [1×42 int32]
%        segcellindex: [1×42 int32]
%          barycoords: [42×3 double]
%        globalcoords: [42×3 double]
%      segmentlengths: [1×41 double]
%          downstream: 1
%           morphogen: []
%         directionbc: [1.5101 -1.5345 0.0244]
%     directionglobal: [-0.0163 -0.0787 0.9968]
%              status: [1×1 struct]
end
