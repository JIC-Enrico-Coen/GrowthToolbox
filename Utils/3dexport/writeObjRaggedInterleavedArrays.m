function writeObjRaggedInterleavedArrays( fid, prefix, varargin )
    if isempty(varargin)
        return;
    end
    a = varargin{1};
    rowlengths = sum(isfinite(a),2);
    lengths = unique(rowlengths);
    if (length(lengths)==1) && (size(a,2)==lengths)
        writeObjInterleavedArrays( fid, prefix, varargin{:} );
    else
        for i=1:length(lengths)
            len = lengths(i);
            arrays = cell(1,length(varargin));
            for j=1:length(varargin)
                a = varargin{j};
                if ~isempty(a)
                    arrays{j} = a( rowlengths==len, 1:len );
                end
            end
            writeObjInterleavedArrays( fid, prefix, arrays{:} );
        end
    end
end