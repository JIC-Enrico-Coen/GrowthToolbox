function b = boolproperty( h, property )
    b = false(size(h));
    for i=1:numel(h)
        b(i) = strcmp( get( h, property ), 'on' );
    end
end
