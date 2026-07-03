function m = addTubuleFate( m, s )
%m = addTubuleFate( m, s )
%   This function is specific to the project GFT_Tubules_20260701.

    [faceaxis1,faceaxis2,edgeaxis] = faceedgecodeToAxes( m, s.faceedgecode );
    
    numRecordedFates = length( m.userdata.tubuleedgefates.edgefate );
    newFateIndex = numRecordedFates+1;
        
    eventstartpoint = s.initialglobalcoords;
    eventendpoint = s.globalcoords(end,:);
    innerbbox = m.auxdata.bbox + [ m.meshparams.edgeradius; -m.meshparams.edgeradius ];
    startvec = abs( eventstartpoint ) - innerbbox(2,:);
    endvec = abs( eventendpoint ) - innerbbox(2,:);
    startangle = atan2( startvec(faceaxis2), startvec(faceaxis1) ); % In range 0..pi/2.
    endangle = atan2( endvec(faceaxis2), endvec(faceaxis1) ); % In range 0..pi/2.
    distanceAroundEdge = m.meshparams.edgeradius( edgeaxis ) * abs(endangle - startangle);
    distanceAlongEdge = abs( eventstartpoint(edgeaxis) - eventendpoint(edgeaxis) );
    angleWithEdge = atan2( distanceAroundEdge, distanceAlongEdge );

    m.userdata.tubuleedgefates.id(newFateIndex,:) = s.id;
%     m.userdata.tubuleedgefates.initialelement(newFateIndex,:) = s.initialelement;
    m.userdata.tubuleedgefates.initialglobalcoords(newFateIndex,:) = eventstartpoint;
%     m.userdata.tubuleedgefates.initialdirectionglobal(newFateIndex,:) = s.initialdirectionglobal;
    m.userdata.tubuleedgefates.eventpoint(newFateIndex,:) = eventendpoint;
    m.userdata.tubuleedgefates.faceedgecode(newFateIndex,:) = s.faceedgecode;
    m.userdata.tubuleedgefates.edgefate(newFateIndex,:) = s.edgefate;
    m.userdata.tubuleedgefates.edgestarttype(newFateIndex,:) = s.edgestarttype;
    m.userdata.tubuleedgefates.distanceAlongEdge(newFateIndex,:) = distanceAlongEdge;
    m.userdata.tubuleedgefates.distanceAroundEdge(newFateIndex,:) = distanceAroundEdge;
    m.userdata.tubuleedgefates.startangle(newFateIndex,:) = startangle;
    m.userdata.tubuleedgefates.endangle(newFateIndex,:) = endangle;
    m.userdata.tubuleedgefates.angleWithEdge(newFateIndex,:) = angleWithEdge;
    m.userdata.tubuleedgefates.faceedgeaxes(newFateIndex,:) = [faceaxis1,faceaxis2,edgeaxis];

    if s.edgefate==0
        xxxx = 1; %#ok<NASGU>
    end
    
    xxxx = 1; %#ok<NASGU>
end