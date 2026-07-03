function [x,removedFields] = safermfield( x, varargin )
%[x,removedFields] = safermfield( x, varargin )
%   Like RMFIELD, but does not throw an exception if a field is not present
%   or if no fields are given. The fields can be given as separate
%   arguments or as a cell array of strings.
% 
%   If the REMOVEDFIELDS output argument is  used, the fields removed from
%   X are copied there. Fields missing from X are not added to
%   REMOVEDFIELDS.

    wantRemovedFields = nargin >= 2;
    if wantRemovedFields
        removedFields = struct();
    end
    if ~isstruct(x), return; end
    if isempty(varargin)
        return;
    end
    if iscell(varargin{1})
%         fields = varargin{1};
%         z = false(1,length(fields));
%         for i = 1:length(fields)
%             z(i) = isfield( x, fields{i} );
%         end
%         remove = fields(z);
        f = varargin{1};
    else
        f = varargin;
    end
    remove = f( isfield( x, f ) );
    if ~isempty(remove)
        if wantRemovedFields
            for ri=1:length(remove)
                removedFields.(remove{ri}) = x.(remove{ri});
            end
        end
        x = rmfield( x, remove );
    end
end

