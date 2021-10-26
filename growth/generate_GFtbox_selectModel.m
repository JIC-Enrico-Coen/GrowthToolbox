function generate_GFtbox_selectModel( m )
    optionnames = fieldnames( m.userdata.ranges );
    fprintf( 1, '        GFtbox_selectModel( ...\n' );
    for i=1:length(optionnames)
        optionname = optionnames{i};
        optionvalues = m.userdata.ranges.(optionname).range;
        optionindex = m.userdata.ranges.(optionname).index;
        if ~iscell(optionvalues)
            optionvalues = mat2cell(optionvalues,1,ones(1,length(optionvalues)));
        end
        optionvalue = optionvalues{optionindex};
        fprintf( 1, '            ''%s'', ', optionname );
        if i==length(optionnames)
            terminator = ' );';
        else
            terminator = ', ...';
        end
        if ischar( optionvalue )
            fprintf( 1, '{' );
            if length(optionvalues) > 1
                fprintf( 1, ' ''%s''', optionvalues{:} );
            end
            fprintf( 1, ' }, ''%s''%s\n', optionvalue, terminator );
        elseif islogical( optionvalue )
            fprintf( 1, '[' );
            if length(optionvalues) > 1
                for j=1:length(optionvalues)
                    fprintf( 1, ' %s', boolchar(optionvalues{j},'true','false') );
                end
            end
            fprintf( 1, ' ], %s%s\n', boolchar(optionvalue,'true','false'), terminator );
        else
            fprintf( 1, '[' );
            if length(optionvalues) > 1
                fprintf( 1, ' %g', optionvalues{:} );
            end
            fprintf( 1, ' ], %g%s\n', optionvalue, terminator );
        end
    end
end
