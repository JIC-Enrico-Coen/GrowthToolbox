function findBadCheckbox( h )
    if isstruct(h)
        f = fieldnames(h);
        for i=1:length(f)
            x = h.(f{i});
            if ishandle(x);
                checkCheckbox(x);
            end
        end
    elseif ishandle(h)
        for i=1:length(h)
            checkCheckbox( h(i) );
            c = get( h(i), 'Children' );
            for j=1:length(c)
                findBadCheckbox(c(j));
            end
        end
    end
end

function checkCheckbox( h )
    if strcmp( tryget( h, 'Style' ), 'checkbox' )
        v = get( h, 'Value' );
        if ~isscalar( v )
            fprintf( 1, 'HERE IT IS %f %s %d\n', ...
                h, get(h,'Tag'), length(get(h,'Value')) );
        end
    end
end
