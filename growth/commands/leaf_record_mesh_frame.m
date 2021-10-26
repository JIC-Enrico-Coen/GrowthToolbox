function m=leaf_record_mesh_frame(m,varargin)
    % It is intended that this will add a file copy of m
    % to a subdirectory of movie
    % 
    % Once RecordMeshes has been turned on either by
    %      using the user interface, 'Movie:Also record meshes'
    %      or by calling this function with arguments
    %      'RECORD','ON' (or turned off with 'RECORD','OFF')
    % then this function is called from 'leaf_movie' each time a 
    % frame is added to a movie.
    % The meshes are stored in a directory with a filename that
    % matches that of the movie.
%
%   Topics: Movies/Images.

    %
    % J. Andrew Bangham, 2008
    
    if isempty(m), return; end
    
%     fprintf( 1, '%s: THIS PROCEDURE IS DISABLED PENDING RECONSTRUCTION.\n', mfilename() );
%     return;
    
    if nargin<2
        if isfield(m.globalProps,'RecordMeshes') ...
                && isfield(m.globalProps.RecordMeshes,'flag') ...
                && m.globalProps.RecordMeshes.flag
            projectdir = m.globalProps.projectdir;
            if isempty(projectdir)
                projectdir = m.projectdir;
            end
            modelname = m.globalProps.modelname;
            m.globalProps.RecordMeshes.saveframe=true; % signal the source of this command to save
            m = leaf_savemodel( m, modelname, projectdir, 'static', false );
            disp('leaf_record_mesh_frame')
        else
            m.globalProps.RecordMeshes.saveframe=false;
            m.globalProps.RecordMeshes.flag=false;
        end
    else
        if length(varargin) < 2
            error('leaf_record_mesh_frame: arguments should be in pairs, i.e. ''RECORD'',''ON''');
        else
            m.globalProps.RecordMeshes.flag = strcmpi(varargin{2},'ON');
            m.globalProps.RecordMeshes.saveframe = false;
        end
    end
end
