function xmlfloatprop( xmlstack, propname, value )
    beginxmlelement( xmlstack, propname );
    contentxmlelement( xmlstack, 'float', value, 'sid', propname );
    endxmlelement( xmlstack, propname );
end
