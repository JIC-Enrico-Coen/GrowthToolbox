function cc = standardizeColourDesc( c )
    if ischar(c)
        % c is a string of one-character names of colours.
        charValues = 'rgbcmywkoa';
        rgbValues = [eye(3); 1-eye(3); 1 1 1; 0 0 0; 1 0.5 0; 0.5 0.5 0.5];
        [isColor,colorIndex] = ismember(c(:),charValues);
        cc = rgbValues( colorIndex(isColor), : );
    elseif size(c,2)==3
        % c is an N*3 array of RGB values.
        cc = c;
    else
        % c is a vector of hue values.  These will be given saturation and
        % value parameters of 1, and the result converted to rgb.  Hues 0
        % and 1 are red, and intermediate values go around the colour wheel
        % from red through yellow, green, blue, violet, and back to red.
        cc = hsv2rgb( [c(:), ones(numel(c),2)] );
    end
end
