function [m,ok] = loadStaticData( m, staticdata )
%[m,ok] = loadStaticData( m, staticdata )
%   Load the static data for the mesh m.
%
%   If staticdata is omitted, this procedure will look for a static file
%   (whose name has the form PROJECTNAME_static.mat) and load data from
%   there.  If staticdata is the name of a file, that file will be used.
%   If staticdata is a struct, it is assumed to be the static data.
%
%   ok will be true if and only if static data was loaded.

    ok = true;
    
    % Determine the static data file name.
    if (nargin < 2) || isempty(staticdata) || (islogical(staticdata(1)) && staticdata(1))
        staticdatafile = fullfile( getModelDir( m ), staticBaseName( m ) );
    elseif ischar( staticdata )
        staticdatafile = staticdata;
    else
        staticdatafile = '';
    end
    
    % Determine the static data struct.
    if ~isempty( staticdatafile )
        % Load the named static data file, if it exists. If it exists but
        % cannot be loaded, an error will be thrown. If it does not exist,
        % a warning message will be printed but execution will continue.
        if exist( staticdatafile, 'file' )==2
            fprintf( 1, '%s: Loading static MAT file %s.\n', ...
                mfilename(), staticdatafile );
            staticdatastruct = load( staticdatafile );
        else
            ok = false;
            fprintf( 1, '%s: Static file not found: %s.\n', ...
                mfilename, staticdatafile );
            staticdatastruct = [];
        end
    elseif isstruct( staticdata )
        % If static data was provided directly, use that.
        staticdatastruct = staticdata;
    else
        % Otherwise, do not load static data.
        staticdatastruct = [];
    end

    if isstruct( staticdatastruct )
        m = addStaticData( m, staticdatastruct );
    end
end
