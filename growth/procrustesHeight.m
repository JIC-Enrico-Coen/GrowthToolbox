function array = procrustesHeight( array, newheight, defaultvalue )
%array = procrustesHeight( array, newwidth, defaultvalue )
%   Force a two-dimensional array to have a given height, by truncating it
%   or padding it with a default value, by default zero.

    if nargin < 3
        defaultvalue = 0;
    end
    curheight = size(array,1);
    if curheight > newheight
        array = array(1:newheight,:);
    elseif curheight < newheight
        array(curheight+1:newheight,:) = defaultvalue + zeros( newheight-curheight, size(array,2) );
    end
end    


