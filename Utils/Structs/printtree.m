function printtree( t, indent )
%printtree( t, indent )
%   Print a tree whose leaves are integers.
    if nargin < 2
        indent = '  ';
    end
    if isnumeric(t)
        fprintf( 1, '%s*', indent );
        fprintf( 1, ' %d', t );
        fprintf( 1, '\n' );
%         for i=1:length(t)
%             fprintf( 1, '%s%d\n', indent, t(i) );
%         end
    else
        for i=1:length(t)
            if isnumeric(t{i})
                if length(t{i})==1
                    fprintf( 1, '%s%d\n', indent, t{i} );
                else
                    fprintf( 1, '%s*', indent );
                    fprintf( 1, ' %d', t{i} );
                    fprintf( 1, '\n' );
                end
            else
                fprintf( 1, '%s*\n', indent );
                printtree( t{i}, [indent, '  '] );
            end
        end
    end
end
