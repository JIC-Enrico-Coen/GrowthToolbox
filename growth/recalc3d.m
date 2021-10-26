function m = recalc3d( m )
%m = recalc3d( m )
%   Call this after the shape of a mesh has been changed, to recalculate
%   various things that depend on the shape.

    m = calcCloneVxCoords( m );
    m = makeAreasAndNormals( m );
    m = calcPolGrad( m );
    m = makebendangles( m );
end
