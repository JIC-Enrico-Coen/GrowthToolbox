function writeObjInterleavedArrays( fid, prefix, varargin )
%writeObjInterleavedArrays( fid, prefix, varargin )
%   Write a set of arrays in OBJ format, in interleaved style, as for face
%   data that combine vertex, uv, and normal indexes.
%   This assumes that the nonempty arrays are of equal size, and contain no
%   NaNs.

    if isempty(varargin)
        return;
    end
    
    numarrays = length(varargin);
    numsets = size(varargin{1},1);
    numitemsperset = size(varargin{1},2);
    itemformat = '';
    nonempty = false(1,length(varargin));
    for i=1:numarrays
        nonempty(i) = ~isempty( varargin{i} );
        if nonempty(i)
            itemformat = [ itemformat '/%g' ];
        else
            itemformat = [ itemformat '/' ];
        end
    end
    data = cell2mat( varargin(nonempty) );
    numnonemptyarrays = sum(nonempty);
    itemformat(1) = ' ';
    lineformat = [ '%s', repmat( itemformat, 1, numitemsperset ), '\n' ];
    
    data = reshape( permute( reshape( data', numitemsperset, numnonemptyarrays, numsets ), [2 1 3] ), [], numsets )';

    
    for i=1:numsets
        fprintf( fid, lineformat, prefix, data(i,:) );
    end
end