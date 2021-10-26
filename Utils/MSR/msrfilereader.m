function [result,errs] = msrfilereader( filename )
%[result,errs] = msrfilereader( filename )
%   Read the given MSR file and return its contents as a Matlab structure.
%   All error messages generated in the process are returned in the cell
%   array of strings ERRS.
%
%   Run this on an example file to see what the returned structure looks
%   like.
%
%   msrfilereader tries to know as little as possible about the data.  It
%   has hard-wired into it the data type associated with each field name
%   (string, integer, or float) and how many data items there should be,
%   but this information should be stored in an external file instead.
%   Unknown field names default to expecting any number of string values.
%
%   Because MSR data indexes its arrays from 0, and Matlab indexes arrays
%   from 1, all array indexes present in the data must be converted from
%   one convention to the other when reading or writing this format.
%   msrfilereader therefore needs to know which fields contain array
%   indexes.  These fields are (currently) assumed to be OBJECT, EDGE, and
%   FACE.  If an MSR file contains any other fields containing array
%   indexes that you are going to use as such, you will have to convert
%   them yourself after reading the data.
%
%   This procedure uses tokeniseString() in the Growth Toolbox.

% The following tables contain everything that this procedure knows about
% specific fields.  They specify, for each field name listed, whether the
% associated data should be strings, floating point numbers, or integers,
% and how many such items there should be on every line that begins with
% that field name.  A count of -1 means that any number of values can be
% given.  All field names not listed here are assumed to expect any number
% of strings.

    labeltypes = struct( ...
        'OBJECT', 's', ...
        'SCALE', 'g', ...
        'TIME', 'g', ...
        'VERT', 'g', ...
        'EDGE', 'd', ...
        'FACE', 'd', ...
        'VERTGROWTH', 'g', ...
        'EDGEGROWTH', 'g', ...
        'FACEGROWTH', 'g', ...
        'EDGEGROWTHDT', 'g', ...
        'FACEGROWTHDT', 'g', ...
        'FACENORMAL', 'g', ...
        'VERTMGEN', 'g', ...
        'VERTMGENNAMES', 's', ...
        'LIST', 'd' );
    labelcounts = struct( ...
        'OBJECT', 1, ...
        'SCALE', 3, ...
        'TIME', 1, ...
        'VERT', 3, ...
        'EDGE', 2, ...
        'FACE', -1, ...
        'VERTMGEN', -1, ...
        'VERTMGENNAMES', -1, ...
        'LIST', -1 );
    parentfields = { 'VERT', 'EDGE', 'FACE', 'VOL' };
    parentpat = parentPattern( parentfields );

    
    result = [];
    errs = {};
    if nargin < 1
        errs{end+1} = [ mfilename(), ': No file given.' ];
        reporterrors();
        return;
    end
    fid = fopen( filename, 'r' );
    if fid==-1
        errs{end+1} = sprintf( '%s: Cannot read file %s.', mfilename(), filename );
        reporterrors();
        return;
    end
    streaminfo = struct( 'fid', fid, ...
                         'filename', filename, ...
                         'line', [], ...
                         'errors', [], ...
                         'indent', 0, ...
                         'linenumber', 0 );
    streaminfo = getline( streaminfo );
    if iseof(streaminfo.line)
        errs{end+1} = [ mfilename(), ': file is empty.' ];
        reporterrors();
        return;
    end
    result = msrreader();
    if ~iseof(streaminfo.line)
        errs{end+1} = sprintf( 'Unexpected material after end of data on line %d: %s\n', ...
            streaminfo.linenumber, streaminfo.line );
    end
    fclose( fid );
    if ~isempty( streaminfo.errors )
        errs = [ errs, streaminfo.errors{:} ];
    end
    
    result = msrConvertBaseIndex( result, 1 );
    reporterrors();

function reporterrors()
    if nargout < 2
        for ei=1:length(errs)
            fprintf( 1, '%s\n', errs{ei} );
        end
    end
end

% Local function, so it has access to streaminfo etc.
function result = msrreader()
    result = [];
    currentObject = [];
    fieldcounts = struct();
    numobjects = 0;
    inHeader = true;
    % Need to check if number of values is consistent, for various fields.
    while true
        if iseof( streaminfo.line )
            if ~isempty(currentObject)
                numobjects = numobjects+1;
                checkCounts( numobjects, fieldcounts );
                result.OBJECT{numobjects} = currentObject;
            end
            return;
        end
        [fieldname,mainfn,subfn,values] = parseline();
        if inHeader
            if strcmp( fieldname, 'OBJECTCOUNT' )
                % Check values is a single integer.
                result.OBJECT = cell( values, 1 );
                inHeader = false;
            else
                result.(fieldname) = values;
            end
        elseif strcmp( fieldname, 'OBJECT' )
            if ~isempty(currentObject)
                numobjects = numobjects+1;
                result.OBJECT{numobjects} = currentObject;
                % Check fieldcounts.
            end
            currentObject = struct( 'OBJECT', values );
            fieldcounts = struct();
        else
      % debugreport( 'msrreader parsing line %d: %s\n', streaminfo.linenumber, streaminfo.line );
            if isempty(subfn)
                subfn = '';
            end
            switch subfn
                case { 'LISTCOUNT' }
                    % Ignore
                case { 'COUNT' }
                    currentObject.(fieldname) = values;
                    currentObject.(mainfn) = initfield( mainfn, values );
                    fieldcounts.(mainfn) = 0;
                case { '', 'NORMAL', 'COLOUR', 'GROWTH', 'MGEN', 'MGENNAMES' }
                    countfield = [ mainfn, 'COUNT' ];
                    havecount = isfield( currentObject, countfield );
                    if ~havecount
                        currentObject.(fieldname) = values;
                    else
                        if ~isfield( currentObject, fieldname ) || isempty( currentObject.(fieldname) )
                            currentObject.(fieldname) = ...
                                initfield( fieldname, currentObject.([ mainfn, 'COUNT' ]), length(values) );
                        end
                        if ~isfield( fieldcounts, fieldname )
                            fieldcounts.(fieldname) = 0;
                        end
                        expnumvals = size( currentObject.(fieldname), 2 );
                        if length(values) < expnumvals
                            values( (end+1):expnumvals ) = -1;
                        elseif length(values) > expnumvals
                            currentObject.(fieldname)(:,(end+1):length(values)) = -1;
                        end
                        newcount = fieldcounts.(fieldname) + 1;
                        currentObject.(fieldname)(newcount,:) = values;
                        fieldcounts.(fieldname) = newcount;
                    end
                case { 'LABEL' }
                    countfn = [ mainfn, 'COUNT' ];
                    havecount = isfield( currentObject, countfn );
                    values = values(2:end);
                    if isempty(values)
                        values = {};
                    end
                    if ~havecount
                        currentObject.(fieldname) = { values };
                    elseif ~isfield( currentObject, fieldname )
                        currentObject.(fieldname) = cell( currentObject.(countfn), 1 );
                        fieldcounts.(fieldname) = 1;
                        currentObject.(fieldname){1} = values;
                    else
                        newcount = fieldcounts.(fieldname) + 1;
                        currentObject.(fieldname){newcount} = values;
                        fieldcounts.(fieldname) = newcount;
                    end
                case 'LIST'
                    label = values{1};
                    indexes = zeros( 1, length(values) - 1 );
                    for i=2:length(values)
                        indexes(i-1) = sscanf( values{i}, '%d' );
                    end
                    if ~isfield( currentObject, fieldname )
                        fieldcounts.(fieldname) = 1;
                        currentObject.(fieldname) = ...
                            struct( 'label', label, 'indexes', indexes );
                    else
                        newcount = fieldcounts.(fieldname) + 1;
                        currentObject.(fieldname)(newcount) = ...
                            struct( 'label', label, 'indexes', indexes );
                        fieldcounts.(fieldname) = newcount;
                    end
                case { 'GROWTHDT' }
                    currentObject.(fieldname) = values;
            end
        end

        streaminfo = getline( streaminfo );
    end

function checkCounts( oi, fieldcounts )
    for fn = fieldnames( fieldcounts )'
        [mainfn,subfn] = splitToken( fn{1}, parentpat );
        countName = [mainfn, 'COUNT'];
        expectedCount = currentObject.(countName);  % fieldcounts.(fn{1});
        actualCount = size( currentObject.(fn{1}), 1 );
        if expectedCount ~= actualCount
            errs{end+1} = [ mfilename(), ...
                sprintf( ': Object %d, field %s: %d records declared, %d found.', ...
                    oi, fn{1}, expectedCount, actualCount ) ]; %#ok<AGROW>
            if expectedCount < actualCount
                currentObject.(fn{1})( (expectedCount+1):end, : ) = [];
            end
        end
    end
end
end

function f = initfield( fieldname, count, width )
    if nargin < 3
        if isfield( labelcounts, fieldname )
            width = labelcounts.(fieldname);
        else
            width = 1;
        end
    end
    if ~isfield( labeltypes, fieldname ) || (labeltypes.(fieldname)=='s')
        f = cell( count, 1 );
    elseif labeltypes.(fieldname)=='d'
        f = -ones( count, width, 'int32' );
    else
        f = -ones( count, width );
    end
end

function [fieldname,mainfn,subfn,values] = parseline()
    fieldname = [];
    values = [];
    mainfn = [];
    subfn = [];
    % Split the line at the '=' sign.
    [starteq,endeq] = regexp( streaminfo.line, '\s*=\s*', 'once', 'start', 'end' );
    if isempty( starteq )
        % Syntax error.
        streaminfo = errorreport( streaminfo, 'No ''='' sign.' );
        return;
    end
    % Force field names to upper case, and check their validity.
    fieldname = upper(streaminfo.line(1:(starteq-1)));
    if isempty( regexp( fieldname, '^[A-Z][A-Z0-9_]*$', 'once' ) )
        streaminfo = errorreport( streaminfo, 'Bad field name ''%s''.', fieldname );
        fieldname = [];
        return;
    end
    [mainfn,subfn] = splitToken( fieldname, parentpat );
    % Get the values as a cell array of strings.
    valuestrings = tokeniseString( streaminfo.line( (endeq+1):end ) );
    debugreport( 'parseline: found field name %s with %d values\n', ...
        fieldname, length(valuestrings) );
    iscountfield = ~isempty( regexp( fieldname, 'COUNT$', 'once' ) );
    if ~iscountfield && (~isfield( labeltypes, fieldname ) || (labeltypes.(fieldname)=='s'))
        % This field expects strings, so return the cell array as the
        % result.
        values = valuestrings;
        if isfield( labeltypes, fieldname )
            nstrings = labelcounts.(fieldname);
            if (nstrings >= 0) && (nstrings ~= length(values))
                if nstrings < length(values)
                    values = values(1:nstrings);
                else
                    values( (end+1):nstrings ) = '';
                end
            end
        end
        if length(values)==1
            values = values{1};
        end
        return;
    end
    debugreport( 'Field %s, iscount %d\n', fieldname, iscountfield );
    
    if iscountfield
        % Count fields expect a single integer.
        fchar = 'd';
        fcount = 1;
    else
        % Other fields expect whatever is specified in labeltypes and
        % labelcounts.  labelcounts defaults to -1 (any number allowed).
        fchar = labeltypes.(fieldname);
        if isfield( labelcounts, fieldname )
            fcount = labelcounts.(fieldname);
        else
            fcount = -1;
        end
    end
    debugreport( 'Format %s, count %d\n', fchar, fcount );
    if (fcount > 0) && (length(valuestrings) ~= fcount)
        streaminfo = errorreport( streaminfo, ...
            '%d values expected, %d found for field %s.', ...
            fcount, length(valuestrings), fieldname );
        return;
    end
    if fchar=='s'
        values = reshape( valuestrings, 1, [] );
        return;
    end
    values = zeros( 1, length(valuestrings) );
    for i=1:length(valuestrings)
        [v,n,errmsg] = sscanf( valuestrings{i}, ['%', fchar], inf ); %#ok<ASGLU>
        if isempty(v) || ~isempty(errmsg)
            streaminfo = errorreport( streaminfo, ...
                'value %d (''%s'') fails to parse as format ''%s'' (%s).', ...
                i, valuestrings{i}, fchar, errmsg );
            values = values(1:(i-1));
            return;
        end
        values(i) = v;
    end
end

function streaminfo = getline( streaminfo )
    while true
        streaminfo.line = fgetl( streaminfo.fid );
        if iseof(streaminfo.line)
            debugreport( 'getline: end of file after %d lines.\n', streaminfo.linenumber );
            streaminfo.indent = 0;
            return;
        end
        streaminfo.linenumber = streaminfo.linenumber+1;
        % Count the size of the leading space.  Strip leading and trailing
        % space.
        streaminfo.indent = regexp( streaminfo.line, '^\s*', 'once', 'end' );
        if isempty(streaminfo.indent)
            streaminfo.indent = 0;
        end
        streaminfo.line = streaminfo.line( (streaminfo.indent+1):end );
        streaminfo.line = regexprep( streaminfo.line, '\s+$', '' );
        % Ignore empty lines.
        if isempty(streaminfo.line)
            continue;
        end
        % Ignore comments.
        if streaminfo.line(1)=='#'
            continue;
        end
      % debugreport( 'getline: read non-null line %d/%d: %s\n', ...
      %     streaminfo.linenumber, streaminfo.indent, streaminfo.line );
        return;
    end
end

function streaminfo = errorreport( streaminfo, varargin )
    % Print an error message and add it to the streaminfo.
    msg = sprintf( varargin{:} );
    fullmsg = sprintf( 'File %s, line %d: %s\n', ...
        streaminfo.filename, streaminfo.linenumber, msg );
    streaminfo.errors{end+1} = fullmsg;
    fwrite( 1, fullmsg );
end
end

function p = parentPattern( tokens )
    p = [ '^(', joinstrings( '|', tokens ), ')(.*)$' ];
end

function [t1,t2] = splitToken( token, pattern )
    t = regexp( token, pattern, 'tokens' );
    if isempty(t)
        t1 = [];
        t2 = [];
    else
        t1 = t{1}{1};
        t2 = t{1}{2};
    end
end


function debugreport( varargin )
% Comment this out to turn all debugging messages off.
%   fprintf( 1, varargin{:} );
end
