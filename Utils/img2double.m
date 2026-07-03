function img = img2double( img )
%img = img2double( img )
%   Convert an image from integers to doubles.  If the img is already of type
%   double this does nothing.
%
%   Signed integers are assumed to be 8-bit unsigned values.
%
%   Unsigned integers are assumed to occupy the full range of their type,
%   e.g. uint16 integers have their full range of 0 to 65535 mapped to
%   0..1, and similarly for uint32 and uint64.
% 
%   This will work when IMG is an array of arbitrary shape.

    if isa( img, 'uint64' )
        img = double(img)/double(uint64(18446744073709551615));
    elseif isa( img, 'uint32' )
        img = double(img)/double(uint32(4294967295));
    elseif isa( img, 'uint16' )
        img = double(img)/65535;
    elseif isinteger(img)
        img = double(img)/255;
    elseif ischar(img)
        img = double(img)/255;
    else
        img = double(img);
    end
end
