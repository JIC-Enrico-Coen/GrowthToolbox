function array = procrustesWidth( array, newwidth, defaultvalue )
%array = procrustesWidth( array, newwidth, defaultvalue )
%   Force a two-dimensional array to have a given width, by truncating it
%   or padding it with a default value, by default zero.

    if nargin < 3
        defaultvalue = 0;
    end
    curwidth = size(array,2);
    if curwidth > newwidth
        array = array(:,1:newwidth);
    elseif curwidth < newwidth
        array(:,curwidth+1:newwidth) = defaultvalue + zeros( size(array,1), newwidth-curwidth, class(array) );
    end
end    


