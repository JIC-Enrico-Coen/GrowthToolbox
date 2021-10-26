function [ok,errs] = msrfilewriter( filename, msr )
%[ok,errs] = msrfilewriter( filename, msr )
%
%   Write an MSR structure as returned by MSRFILEREADER to the given file.
%   If the filename is empty then output will be to the console.
%   If MSR is missing or empty then no file will be touched.
%   OK is a boolean to say whether the operation succeeded.  If it fails,
%   ERRS will be a cell array of associated error message strings.
%
%   Because MSR data indexes its arrays from 0, and Matlab indexes arrays
%   from 1, all array indexes present in the data must be converted from
%   one convention to the other when reading or writing this format.
%   msrfilewriter therefore needs to know which fields contain array
%   indexes.  These fields are (currently) assumed to be OBJECT, EDGE, and
%   FACE.  If an MSR file contains any other fields containing array
%   indexes that you are going to use as such, you will have to convert
%   them yourself before writing the data.

    ok = true;
    errs = {};
    if (nargin < 2) || isempty( msr )
        ok = false;
        errs{end+1} = [ mfilename(), ': No MSR data given.' ];
        return;
    end
    if ~isstruct( msr )
        ok = false;
        errs{end+1} = sprintf( ...
                        '%s( filename, msr ): MSR data expected to be a struct, %s found.', ...
                        mfilename(), class( msr ) );
        return;
    end
    if isempty( filename )
        fid = 1;
    else
        fid = fopen( filename, 'w' );
        if fid==-1
            ok = false;
            errs{end+1} = sprintf( '%s: Cannot write file %s.', mfilename(), filename );
            return;
        end
    end
    
    msr = msrConvertBaseIndex( msr, 0 );
    
    printmsrversion( fid, msr );
    msr = safermfield( msr, 'MSR_VERSION' );
    fns = fieldnames(msr);
    
    for i=1:length(fns)
        fn = fns{i};
        if ~strcmp( fn, 'OBJECT' ) && ~strcmp( fn, 'OBJECTCOUNT' )
            printfield( fid, msr, fn );
        end
    end
    fprintf( fid, 'OBJECTCOUNT = %d\n', length( msr.OBJECT ) );
    for i=1:length(msr.OBJECT)
        printstruct( fid, msr.OBJECT{i} );
    end
    
    if fid ~= 1
        fclose( fid );
    end
end

function printmsrversion( fid, msr )
    if ~isfield( msr, 'MSR_VERSION' )
        return;
    end
    if isempty( msr.MSR_VERSION )
        return;
    end
    fprintf( fid, 'MSR_VERSION = %s\n', msr.MSR_VERSION );
end

function printfield( fid, msr, fn )
    NEWLINE = char(10);
    msr1 = msr.(fn);
    if isempty( msr1 )
        return;
    end
    countfn = [ fn, 'COUNT' ];
    havecount = isfield( msr, countfn );
    if havecount
        thecount = msr.(countfn);
    else
        thecount = 0;
    end
    if havecount
        printcount( fid, fn, thecount );
    end
    if ischar( msr1 )
        printfieldname( fid, fn );
        fwrite( fid, ' ' );
        printquotedstring( fid, msr1 );
        fwrite( fid, NEWLINE );
    elseif iscell( msr1 )
        if ischar( msr1{1} )
            printfieldname( fid, fn );
            for j=1:length(msr1)
                fwrite( fid, ' ' );
                printquotedstring( fid, msr1{j} );
            end
            fwrite( fid, NEWLINE );
        elseif isstruct( msr1{1} )
            for j=1:length(msr1)
                printstruct( fid, msr1{j} );
            end
        elseif isnumeric( msr1{1} )
            for j=1:length(msr1)
                printfieldname( fid, fn );
                printvec( fid, msr1{j} );
                fwrite( fid, NEWLINE );
            end
        end
    elseif isnumeric( msr1 )
        sz = size( msr1 );
        if length(sz) > 2
            errorreport
        else
            for j=1:sz(1)
                printfieldname( fid, fn );
                printvec( fid, msr1(j,:) );
                fwrite( fid, NEWLINE );
            end
        end
    elseif isstruct( msr1 ) && isfield( msr1, 'label' )
        for i=1:length(msr1)
            fprintf( fid, '%s = ', fn );
            printquotedstring( fid, msr1(i).label );
            fprintf( fid, ' %d', msr1(i).indexes );
            fwrite( fid, NEWLINE );
        end
    else
%         ok = false;
%         errs{end+1} = sprintf( '%s: Unknown data type %s for field %s, nesting %d.', ...
%             mfilename(), fn, class(msr1) );
    end
    labelfn = [ fn, 'LABEL' ];
    havelabel = isfield( msr, labelfn );
    if havelabel
        for i=1:length( msr.(labelfn) )
            l = msr.(labelfn){i};
            if ischar(l)
                fprintf( fid, '%s = 1 ', labelfn );
                printquotedstring( fid, l );
            else
                fprintf( fid, '%s = %d', labelfn, length(l) );
                for j=1:length(l)
                    fwrite( fid, ' ' );
                    printquotedstring( fid, l{j} );
                end
            end
            fwrite( fid, char(10) );
        end
    end
end

function printstruct( fid, msr )
    if isempty( msr )
        return;
    end
    fns = fieldnames( msr );
    for j=1:length(fns)
        fn = fns{j};
        if isempty( regexp( fn, 'COUNT$', 'once' ) ) && isempty( regexp( fn, 'LABEL$', 'once' ) ) && isempty( regexp( fn, 'children$', 'once' ) )
            printfield( fid, msr, fn );
        end
    end
end

function printcount( fid, fn, n )
    printfieldname( fid, [fn, 'COUNT'] );
    fprintf( fid, ' %d\n', n );
end
    
function printvec( fid, v )
    if all( v==round(v) )
        fprintf( fid, ' %d', v );
    else
        fprintf( fid, ' %.8g', v );
    end
end

function printfieldname( fid, fn )
    fwrite( fid, [ fn, ' =' ] );
end

function printquotedstring( fid, s )
    if true % regexp( s, '[''\\ ]' )
        s = [ '''', regexprep( s, '([''\\])', '\\$1' ), '''' ];
    end
    fwrite( fid, s );
end

