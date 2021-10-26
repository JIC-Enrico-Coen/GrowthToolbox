function dumpFigure( fig, indent )
%dumpFigure( fig )
%   Print an indented list of the contents of the figure.

    if nargin < 2
        indent = 0;
    end
    
    name = tryget( fig, 'Name' );
    type = tryget( fig, 'Type' );
    tag = tryget( fig, 'Tag' );
    spacing( 1, indent*2 );
    fprintf( 1, '%s ''%s'' ''%s''\n', type, tag, name );
    c = get( fig, 'Children' );
    newindent = indent+1;
    for i=1:length(c)
        dumpFigure( c(i), newindent );
    end
end
