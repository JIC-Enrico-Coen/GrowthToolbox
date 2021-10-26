function showRSSS( fid, s, indent )
%showRSSS( fid, s, indent )
%   Write to the console a pretty-printed form of the dialog description s.
%   The indent defaults to 0.

    if nargin < 3
        indent = 0;
    end
    printindent( fid, indent );
    fprintf( fid, '%s ', s.type );
    numAttribs = length(fieldnames( s.attribs ));
    hasChildren = ~isempty( s.children );
    if (numAttribs==1) && ~hasChildren
        fn = fieldnames( s.attribs );
        fn = fn{1};
        v = s.attribs.(fn);
        if isempty(v) || regexp( v, ' ' )
            fprintf( fid, '{ %s "%s" }\n', fn, v );
        else
            fprintf( fid, '{ %s %s }\n', fn, v );
        end
    elseif (numAttribs>0) || hasChildren
        fprintf( 1, '{\n' );
        if numAttribs>0
            showRSSattribs( fid, s.attribs, indent+1 );
        end
        for i=1:length(s.children)
            showRSSS( fid, s.children{i}, indent+1 );
        end
        printindent( fid, indent );
        fprintf( 1, '}\n' );
    else
        fprintf( 1, '{ }\n' );
    end
end

function showRSSattribs( fid, attribs, indent )
    fn = fieldnames(attribs);
    for i=1:length(fn)
        printindent( fid, indent );
        fprintf( 1, '%s ', fn{i} );
        v = attribs.(fn{i});
        if isnumeric(v)
            switch numel(v)
                case 0
                    fprintf( fid, '[]\n' );
                case 1
                    fprintf( fid, '%f\n', v );
                otherwise
                    fprintf( fid, '%f ', v(1:(end-1)) );
                    fprintf( fid, '%f\n', v(end) );
            end
        elseif islogical(v)
            truthvalues = { 'false', 'true' };
            switch numel(v)
                case 0
                    fprintf( fid, '[]\n' );
                otherwise
                    for j=1:length(v)-1
                        fprintf( fid, '%s ', truthvalues{v(j)+1} );
                    end
                    fprintf( fid, '%s\n', truthvalues{v(end)+1} );
            end
        elseif iscell( v )
            fprintf( fid, '"%s"\n', joinstrings( '|', v ) );
        elseif isempty(v) || ~isempty(regexp( v, ' ' ))
            fprintf( fid, '"%s"\n', v );
        else
            fprintf( fid, '%s\n', v );
        end
    end
end

function printindent( fid, indent )
    fprintf( fid, repmat( '     ', 1, indent ) );
end