function [options,index] = setOptionIndex( options, optionname, value )
    optionname = makeValidName( optionname );
    if isempty(optionname)
        index = -1;
        return;
    end
    if ~isfield( options, optionname )
%         if ischar(value)
%             options.(optionname).range = { value };
%         else
%             options.(optionname).range = value;
%         end
        options.(optionname).range = [];
        index = 1;
    elseif isempty( options.(optionname).range )
        index = 0;
    else
        if ischar(value)
            index = find(strcmp(options.(optionname).range,value),1);
        elseif iscell( options.(optionname).range )
            index = find(cell2mat(options.(optionname).range)==value,1);
        else
            index = find(options.(optionname).range==value,1);
        end
        if isempty( index )
            fprintf( 'Option %s has unknown value %s, alternatives are:\n    ', optionname, value );
            if iscell( options.(optionname).range )
                fprintf( 1, ' %s', options.(optionname).range{:} );
            else
                fprintf( 1, ' %g', options.(optionname).range );
            end
            fprintf( 1, '\n' );
            if ischar(value)
                options.(optionname).range = { value };
            else
                options.(optionname).range = value;
            end
            index = 1;
        end
    end
    options.(optionname).value = value;
    options.(optionname).index = index;
end
