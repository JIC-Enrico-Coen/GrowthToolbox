function m = pullbackAirSpaces( m, a )
%m = pullbackAirSpaces( m, a )
%   Smooth out the inward-bulging walls of air spaces.

% old3dcoords = m.secondlayer.cell3dcoords;

    numbiocells = length(m.secondlayer.cells);
    for i=1:numbiocells
        nbcells = m.secondlayer.edges( m.secondlayer.cells(i).edges, [3 4] );
        airborder = any(nbcells == -1,2);
        conseqAirBorder = find( airborder & airborder( [end (1:(end-1))] ) );
        if length(conseqAirBorder) >= 1
            nv = length( m.secondlayer.cells(i).edges );
            preVertex = 1 + mod( conseqAirBorder + nv - 2, nv );
            postVertex = 1 + mod( conseqAirBorder, nv );
            vxsSmoothing = [ m.secondlayer.cells(i).vxs(preVertex); ...
                            m.secondlayer.cells(i).vxs(conseqAirBorder); ...
                            m.secondlayer.cells(i).vxs(postVertex) ];
            newVxCoords = (1-a) * m.secondlayer.cell3dcoords( m.secondlayer.cells(i).vxs(conseqAirBorder), : ) ...
                          + (a/2) * (m.secondlayer.cell3dcoords( m.secondlayer.cells(i).vxs(preVertex), : ) ...
                                     + m.secondlayer.cell3dcoords( m.secondlayer.cells(i).vxs(postVertex), : ));
            m.secondlayer.cell3dcoords( vxsSmoothing(2,:), : ) = newVxCoords;
            % Get FE and barycoords for each.
            for j=1:length(conseqAirBorder)
                vj = vxsSmoothing( 2, j );
                fprintf( 1, 'Smoothing cell %d, vertex %d.\n', j, vj );
                [ ci, bc, bcerr, abserr ] = findFE( m, newVxCoords(j,:), 'hint', m.secondlayer.vxFEMcell(vj,:) );
                m.secondlayer.vxFEMcell(vj) = ci;
                m.secondlayer.vxBaryCoords(vj,:) = bc;
            end
        end
    end
    
% moved = m.secondlayer.cell3dcoords ~= old3dcoords;
% anymoved = any( moved, 2 );
% whichmoved = find( anymoved )
% moves = m.secondlayer.cell3dcoords( whichmoved, : ) - old3dcoords( whichmoved, : )
end
