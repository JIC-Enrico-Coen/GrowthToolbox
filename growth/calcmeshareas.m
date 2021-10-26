function m = calcmeshareas( m )
%m = calcmeshareas( m )
%   Calculate the area of every cell of the mesh.

%   This routine must not assume the existence of any fields except nodes
%   and tricellvxs.  It should set m.cellareas and some components of
%   m.globalProps and m.globalDynamicProps.

    if usesNewFEs(m)
        foo = reshape( m.FEnodes( m.FEsets(1).fevxs', : ), size(m.FEsets(1).fevxs,2), size(m.FEsets(1).fevxs,1), size(m.FEnodes,2) );
        maxpts = max(foo, [], 1 );
        minpts = min(foo, [], 1 );
        avbbox = sum( squeeze( maxpts-minpts ), 1 ) / size(m.FEsets(1).fevxs,1);
        m.globalDynamicProps.cellscale = sum(avbbox)/length(avbbox);
        m = calcFEvolumes( m );
        return;
    end

    numcells = getNumberOfFEs(m);
    if (~isfield( m, 'cellareas' )) || (length( m.cellareas ) ~= numcells)
        m.cellareas = zeros(numcells,1);
    end
    m.cellareas = findFEareas( m );
    if ~isfield( m, 'globalProps' )
        m.globalProps = struct();
    end
    m.globalDynamicProps.currentArea = sum( m.cellareas );
    m.globalDynamicProps.cellscale = sqrt( m.globalDynamicProps.currentArea / numcells );
end

