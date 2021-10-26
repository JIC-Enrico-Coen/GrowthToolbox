function img = convertImageType( img, desiredtype )
%img = convertImageType( img, desiredtype )
%   DESIREDTYPE is 'logical', 'double', or the name of any of the integer
%   types. The given image will be converted to this type, with its values
%   appropriately rescaled.

    imgtype = class(img);
    if strcmp( imgtype, desiredtype )
        return;
    end
    bitwidths = struct( 'uint8', 8, 'uint16', 16, 'uint32', 32, 'uint64', 64, 'logical', 1, 'single', Inf, 'double', Inf );
    if ~isfield( bitwidths, imgtype ) || ~isfield( bitwidths, desiredtype )
        return;
    end
    sourcewidth = bitwidths.(imgtype);
    targetwidth = bitwidths.(desiredtype);
    img = double(img);
    if sourcewidth ~= Inf
        img = img/(2^sourcewidth-1);
    end
    if targetwidth ~= Inf
        img = img*(2^targetwidth-1);
    end
    img = settype( desiredtype, img );
end

function x = settype( class, x )
    f = str2func(class);
    x = f(x);
end

