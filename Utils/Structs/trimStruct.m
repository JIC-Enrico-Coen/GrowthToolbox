function s = trimStruct( s, varargin )
%s = trimStruct( s, fields )
%   Remove all fields from s except those in the cell array FIELDS.
%   FIELDS can instead be a struct, and fields with be removed from s that
%   are not fields of that struct.
%s = trimStruct( s, field1, field2, ... )
%   The field names can be given as separate arguments.

    if isempty(varargin)
        return;
    end
    
    if isstruct(varargin{1})
        fields = fieldnames(varargin{1});
    elseif iscell(varargin{1})
        fields = varargin{1};
    else
        fields = varargin;
    end
    
    s = rmfield( s, setdiff( fieldnames(s), fields ) );
end
