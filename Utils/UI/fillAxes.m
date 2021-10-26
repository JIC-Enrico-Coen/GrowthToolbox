function fillAxes( h, color )
%fillAxes( h, color )
%   Clear the axes object h and fill it with the given colour.

    cla(h);
    hpos = get( h, 'Position' );
    fill( [0; 0; hpos(3); hpos(3)], [0; hpos(4); hpos(4); 0], color, 'LineStyle', 'none', 'Parent', h );
    axis( h, [ 0 hpos(3) 0 hpos(4) ] );
    axis( h, 'off' );
    view( h, 0, 90 );
end

