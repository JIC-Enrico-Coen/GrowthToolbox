function titleFigure( fig, s, varargin )
% Add a title to a figure as a text object within the figure, placed along
% the bottom.

    fpos = fig.Position;
    t = uicontrol( 'Parent', fig, 'Style', 'text', 'String', s, varargin{:} );
    tpos = t.Position;
    newtpos = [0, 0, fpos(3), tpos(4)];
%     fprintf( 1, 'Figure pos [%f %f %f %f], text pos [%f %f %f %f]\n', fpos, newtpos );
    t.Position = newtpos;
end
