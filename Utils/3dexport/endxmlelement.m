function endxmlelement( xmlstack, name )
%beginxmlelement( xmlstack, name )
%   Write the closing of an XML element.  The name of the element is also
%   popped off the stack XMLSTACK.  The name is optional, since it should
%   be identical to the top element of XMLSTACK.  If provided, it will be
%   checked against it and a warning issued if it is different or if the
%   stack is empty.

    n = xmlstack.len();
    v = xmlstack.pop();
    if nargin < 2
        if n==0
            error( 'XML element stack underflow.' );
        end
        name = v;
    else
        if n==0
            error( 'XML element stack underflow: expected to find "%s".', name );
        elseif ~strcmp( v, name )
            error( 'Unexpected end of element type "%s", expected "%s".', name, v );
        end
    end
    
    fprintf( xmlstack.fid, '%s</%s>\n', repmat( '  ', 1, xmlstack.len() ), name );
end
    