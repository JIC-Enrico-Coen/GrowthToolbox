function ok = checkMenuLengths( mh, maxlen )
%ok = checkMenuLengths( mh, maxlen )
%   Check that neither the menu mh nor any of its descendants has more than
%   maxlen children.

    c = get( mh, 'Children' );

    if length(c) > maxlen
        ok = false;
        return;
    end
    
    for i=1:length(c)
        if ~checkMenuLengths( c(i), maxlen )
            ok = false;
            return;
        end
    end
    
    ok = true;
end
