function ax = getFlatAxes( m )
%ax = getFlatAxes( m )
%   Find which dimension m is thinnest in.  The result is a triple [x,y,z],
%   where z is the index of the thinnest axis, and x and y are the next two
%   axes in cyclic order.
    
    if isVolumetricMesh( m )
        ax = [];
        return;
    end
    bbox = [min(m.nodes,[],1); max(m.nodes,[],1)];
    bboxdiam = bbox(2,:) - bbox(1,:);
    [~,normalaxis] = min( bboxdiam );
    ax = [ othersOf3( normalaxis ), normalaxis ];
end
