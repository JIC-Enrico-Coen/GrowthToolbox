function optionValue = sanitiseSpreadsheetValue( optionValue )
    if numel( optionValue )==1
        return;
    end
    
    if all(ischar( optionValue )) || all(isstring( optionValue ))
        return;
    end
    
    if isnumeric( optionValue )
        optionValue = reshape( optionValue, [], 1 );
        if all( optionValue==int32(optionValue) )
            optionValue = sprintf( '%d ', optionValue );
        else
            optionValue = sprintf( '%g ', optionValue );
        end
        optionValue(end) = '';
        return;
    end
    
    if isa( optionValue, 'missing' )
        optionValue = '';
        return;
    end
    
    optionValue = '[UNKNOWN]';
end
