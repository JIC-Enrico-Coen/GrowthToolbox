function ok = consistentMeshDelInfo( m, delinfo, afterdeletion )
    ok = consistentDelInfo( delinfo );
    if ok
        if afterdeletion
            fn = 'keeplist';
        else
            fn = 'keepmap';
        end
        ok1 = length(delinfo.fevx.(fn))==getNumberOfVertexes(m);
        ok2 = length(delinfo.fe.(fn))==getNumberOfFEs(m);
        ok3 = length(delinfo.feedge.(fn))==getNumberOfEdges(m);
        ok4 = length(delinfo.cellvx.(fn))==getNumberOfCellvertexes(m);
        ok5 = length(delinfo.cell.(fn))==getNumberOfCells(m);
        ok6 = length(delinfo.celledge.(fn))==getNumberOfCellEdges(m);
        % Don't check mgen or cellmgen.
        fprintf( 1, 'consistentMeshDelInfo: fevx %d fe %d feedge %d cellvx %d cell %d celledge %d\n', ok1, ok2, ok3, ok4, ok5, ok6 );
        ok = all( [ok1, ok2, ok3, ok4, ok5, ok6] );
    end
end

function ok = consistentDelInfo( delinfo )
    ok = true;
    fns = fieldnames( delinfo );
    for fi=1:length(fns)
        fn = fns{fi};
        s = delinfo.(fn);
        ok1 = sum(s.delmap)==length(s.dellist);
        ok2 = sum(s.keepmap)==length(s.keeplist);
        ok3 = length(s.remap)==length(s.delmap);
        ok4 = length(s.remap)==length(s.keepmap);
        ok1a = isa( s.delmap, 'logical' );
        ok2a = isa( s.dellist, 'int32' );
        ok3a = isa( s.keepmap, 'logical' );
        ok4a = isa( s.keeplist, 'int32' );
        ok5a = isa( s.remap, 'int32' );
        fprintf( 1, 'consistentDelInfo: %8s del %d %d %d keep %d %d %d re-del %d re-keep %d re-type %d\n', ...
            fn, ok1a, ok2a, ok1, ok3a, ok4a, ok2, ok3, ok4, ok5a );
        ok1 = all( [ ok1a, ok2a, ok1, ok3a, ok4a, ok2, ok3, ok4, ok5a ] );
        if ~ok1
            xxxx = 1;
        end
        ok = ok && ok1;
    end
end

