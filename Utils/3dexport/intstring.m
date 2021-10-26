function s = intstring( f )
%s = intstring( f )
%   Convert an array of integers to a string.

    if isempty(f)
        s = '';
    elseif numel(f)==1
        s = sprintf( '%d', f );
    else
        s = [ sprintf( '%d', f(1) ), sprintf( ' %d', f(2:end) ) ];
    end
end