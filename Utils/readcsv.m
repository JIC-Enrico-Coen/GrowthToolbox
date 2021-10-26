function [data,headers] = readcsv( filename )
%[data,headers] = readcsv( filename )
%   Read CSV data from the named file.  The first line of the file is
%   assumed to give a name to each column.  These names will be returned in
%   the cell array HEADERS.  The data are returned in the array DATA, with
%   one row for every line in the file and one column for every field.
%   Missing values will be returned as zero.

    fid = fopen( filename, 'r' );
    if fid==-1
        error( 'RK:readcsv', 'File %s not found.', filename );
        return;
    end
    data = [];
    headers = {};
    x = fgetl( fid );
    if iseof( x )
        error( 'RK:readcsv', 'No data in file %s.', filename );
        return;
    end
    headers = splitString( ',', x );
    numfields = length(headers);
    data = textscan( fid, '%f', inf, 'Delimiter', ', ' );
    data = data{1};
    fclose( fid );
    rmdr = mod(length(data),numfields);
    if rmdr ~= 0
        data((end-rmdr+1):end) = [];
    end
    data = reshape( data, numfields, [] )';
end
