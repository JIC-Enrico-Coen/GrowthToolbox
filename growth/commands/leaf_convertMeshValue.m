function [result,ok] = leaf_convertMeshValue( m, varargin )
% INCOMPLETE, IN PROGRESS 2018-08-13
% This is a single procedure to unify all of the functions converting
% between per-FE, per-vertex, per-cell, and per-cell-vertex values.

    result = [];
    ok = false;
    if isempty(m)
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'from', [], 'to', [], 'value', [], 'subset', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'from', 'to', 'value', 'subset' );
    if ~ok, return; end
    
    if isempty( s.value )
        ok = true;
        return;
    end
    
    formats = { 'FE', 'FEvertex', 'Cell', 'Cellvertex' };
    fromi = find( strcmpi( s.from, formats ), 1 );
    if isempty(fromi)
        fprintf( 1, 'Unrecognised ''from'' format ''%s''.\n', s.from );
        return;
    end
    toi = find( strcmp( s.to, formats ), 1 );
    if isempty(toi)
        fprintf( 1, 'Unrecognised ''to'' format ''%s''.\n', s.to );
        return;
    end
    
    procname = [ formats{fromi} 'To' formats{toi} ];
    if exist( procname, 'file' ) ~= 2
        fprintf( 1, 'Conversion procedure ''%s'' not found.\n', procname );
        return;
    end
    result = eval( [ procname, '( m, s.value, s.subset )' ] );
    ok = true;
end
