function beginxmlelement( xmlstack, name, varargin )
%beginxmlelement( xmlstack, name, ... )
%   Write the opening of an XML element, where the variable arguments give
%   its attributes (all as strings).  The name of the element is also
%   pushed onto the stack XMLSTACK.

    indentlevel = xmlstack.len();
    xmlstack.push( name );
    fprintf( xmlstack.fid, '%s<%s', repmat( '  ', 1, indentlevel ), name );
    for i=1:2:length(varargin)
        fprintf( xmlstack.fid, ' %s="%s"', varargin{i}, varargin{i+1} );
    end
    fprintf( xmlstack.fid, '>\n' );
end
    