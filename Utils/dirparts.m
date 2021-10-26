function [parent,basename] = dirparts( dirname )
%[parent,basename] = dirparts( dirname )
%   Like fileparts(), but does not treat file extensions specially.
%   Directory names can contain "." characters, but these should not be
%   understood as separating a base name from an extension.

    [parent,basename,baseext] = fileparts( dirname );
    basename = [ basename,baseext ];
end