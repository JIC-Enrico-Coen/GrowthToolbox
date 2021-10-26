function saveStructFields( filename, s, varargin )
%saveStructFields( filename, s, ... )
%   Save specified fields from a structure into a file.  The field names
%   can be given either as a series of string arguments or as a single cell
%   array of strings.  If any specified fields are not present in s they
%   are silently ignored.  If no fields are supplied, or none of the
%   specified fields are present, then no file will be written.

    if isempty( varargin )
        return;
    end
    if iscell( varargin{1} )
        fieldnames = varargin{1};
    else
        fieldnames = varargin;
    end
    fieldnames = fieldnames( isfield( s, fieldnames ) );
    if isempty( fieldnames )
        return;
    end
    save( filename, '-struct', 's', fieldnames{:} );
    % The resulting file should be loaded with
    %   s = load( filename );
    % and the resulting structure will contain exactly the fields that were
    % saved.
end
