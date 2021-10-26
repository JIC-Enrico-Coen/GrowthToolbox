function rawmesh = readrawmesh( dirname, basename )
%rawmesh = readrawmesh( dirname, basename )
%    Read a mesh from the set of files in the given directory having the
%    given basename.  If basename is the name of a subdirectory, read the mesh
%    from the set of files contained in that subdirectory.
%    It does not matter whether dirname has a trailing '/' or not.
%    Basename should not contain wildcards.
%
%    If basename is empty, dirname will be taken to be the full file name
%    or directory name.
%
%    In each file, comments begin with a #, extend to the end of the
%    line, and are ignored.  Empty lines are ignored.  Leading and trailing
%    space is ignored.  Each remaining line is expected to begin with a
%    token, made of letters, digits, underscores, and hyphens (but hyphens
%    will be taken as equivalent to underscores).  The token is followed by
%    series of numbers separated by whitespace.  The same token must always
%    be followed by the same number of numbers.  Extra numbers will be
%    ignored and missing numbers set to zero, with a warning printed.
%    In addition, a line consisting entirely of numbers is allowed: in this
%    case the implied token name is the file extension (with invalid
%    characters removed).  If the file has no file extension, the basename
%    of the file is used.
%
%    The result of reading the raw data is a structure containing a field
%    for each different token that was seen.  The value of that field is a
%    matrix in which each row corresponds to a line of data readin from the
%    files.  When reading multiple files, it does not matter which file any
%    piece of data came from.
%
%    2008 Feb 27: readrawmesh cannot be used to read prim meshes, only
%    triangular meshes.

% This operates by first reading in all of the data, and then constructing
% a mesh from it.

    rawmesh = [];
    if nargin < 2, basename = ''; end

    fullname = fullfile( dirname, basename );
    [dirname,stem,ext] = fileparts(fullname);
    basename = [ stem, ext ];
    files = [];
    if isempty(ext)
        files = dir( [ fullname, '.*' ] );
    end
    if isempty(files)
        files = dir( fullname );
    end
    if isempty(files)
        fprintf( 1, 'No files or subdirectories %s found.\n', fullname );
        return;
    end
    df = files([files.isdir]);
    if (~isempty(df)) && (length(df) ~= length(files))
        fprintf( 1, 'Mixture of files and directories for %s.\n', fullname );
        return;
    end
    if ~isempty(df)
        files = [];
        for x = df
            f1 = dir( [ dirname, x.name ] );
            f1 = f1(~[f1.isdir]);
            for i=1:length(f1)
                f1(i).name = fullfile( x.name, f1(i).name );
            end
            files = [files;f1];
        end
        if isempty(files)
            fprintf( 1, 'No files found in subdirectories of %s with names %s or %s.*.\n', ...
                 dirname, basename, basename );
            return;
        end
    end
    formats = struct( ...
        'f', '%d', ...
        'x_growth', '%d %f %f %f' );
    for i=1:length(files)
        % read mesh info from file
        filename = fullfile( dirname, files(i).name );
        rawmesh = addToRawMesh( rawmesh, filename, formats );
    end
end

