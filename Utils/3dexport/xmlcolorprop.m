function xmlcolorprop( xmlstack, propname, value )
    beginxmlelement( xmlstack, propname );
    contentxmlelement( xmlstack, 'color', value, 'sid', propname );
    endxmlelement( xmlstack, propname );
end
