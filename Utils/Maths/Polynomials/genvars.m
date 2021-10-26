function v = genvars( base, num, start )
    if nargin < 3
        start = 1;
    end
    v = cell(1,num);
    numdigits = length(sprintf( '%d', start+num-1 ));
    for i=start:(start+num-1)
        v{i-start+1} = char( [ base, sprintf( '%0*d', numdigits, i ) ] );
    end
end
