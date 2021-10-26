function c = struct2args( s )
%c = struct2args( s )
%   Concert a struct to a cell array of alternating field names and values,
%   suitable for passing as optional arguments to a function.

    f = fieldnames(s);
    v = struct2cell(s);
    c = reshape( { f{:}; v{:} }, 1, [] );
end
    
