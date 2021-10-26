function f = makeCentredFigure( sz )
    f = figure( 'Position', [0 0 sz], 'Visible', 'off' );
    movegui( f, 'center' );
    set(f,'Visible','on');
end