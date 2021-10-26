function [revs,dates] = svnrevision( dirname, recurse )
%[revs,dates] = svnrevision( dirname, recurse )
%   Find the SVN revision number and date of revision of a directory, and
%   optionally, all its subdirectories.  In the latter case, if there is
%   more than one revision number, the list of revision numbers and dates
%   found will be returned in reverse chronological order, with duplicates
%   omitted.  revs(1) is therefore always the most recent revision found,
%   and dates{1} the most recent revision date.
%
%   If a directory is not under SVN control, revs is 0 and dates is ''.
%   In a recursive search, subdirectories whose name begins with '.' are
%   ignored.  DIRNAME itself can begin with a '.' and will be searched.
%
%   If a directory is not under SVN control, its subdirectories will still
%   be searched.
%
%   WARNING AND IMPLEMENTATION:
%
%   The documentation for SVN explicitly denies offering any way to read
%   this information, so I have had to discover where it resides by trial
%   and error.  Since it is undocumented, my code might break in future
%   revisions of SVN, and I cannot be sure that it will work under all
%   circumstances in the current version of SVN.
%
%   The method is to look in the file .svn/entries.  The third token in
%   this file is the revision number, and the sixth is the date in Zulu
%   format.
%
%   Richard Kennaway 2011.

    if nargin < 2
        recurse = false;
    end
    if (nargin < 1) || isempty( dirname )
        dirname = pwd();
    end
    if recurse
        [revs,dates] = svnrevisionrec( dirname );
%         revs = unique(revs);
%         revs = revs(length(revs):-1:1);
%         dates = unique(dates);
%         dates = dates(length(dates):-1:1);
    else
        [revs,dates] = svnrevision1( dirname );
    end
end

function [revs,dates] = svnrevisionrec( dirname )
    [revs,dates] = svnrevision1( dirname );
    dates = { dates };
    contents = dirnames( dirname );
    for i=1:length(contents)
        f = contents{i};
        if f(1)=='.'
            continue;
        end
        if exist(f,'dir')
            [newrevs,newdates] = svnrevisionrec( fullfile( dirname, f ) );
            revs = [ revs, newrevs ];
            dates = [ dates, newdates ];
        end
    end
end

function [rev,date] = svnrevision1( dirname )
    entriesfile = fullfile( dirname, '.svn', 'entries' );
    rev = 0;
    date = '';
    if ~exist( entriesfile, 'file' )
        return;
    end
    fid = fopen( entriesfile, 'r' );
    if fid == -1
        return;
    end
    count = 0;
    while true
        s = fgetl( fid );
        if (length(s)==1) && (s==-1)
            break;
        end
        s = regexprep( s, '^\s*', '' );
        s = regexprep( s, '\s*$', '' );
        tokens = splitString( '\s+', s );
        newcount = count+length(tokens);
        if (count < 3) && (newcount >= 3)
            [rev,n] = sscanf( tokens{3-count}, '%d', 1 );
            if n ~= 1
                rev = 0;
            end
        end
        if (count < 6) && (newcount >= 6)
            date = tokens{6-count};
            break;
        end
        count = newcount;
    end
    fclose(fid);
end
