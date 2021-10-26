function iftext = loadIFtemplate( templatefile, ifdata )
    fulltemplatefile = fullfile( GFtboxDir(), 'IFtemplates', [templatefile,'.txt'] );
    [iftext,ok] = readtextfile( fulltemplatefile );
    if ~ok
        complain( '%s: Failed to find interaction function template file %s in directory %s.txt.', ...
            mfilename(), templatefile, fullfile( GFtboxDir(), 'IFtemplates' ) );
        return;
    end
    if nargin > 1
        iftext = insertdata( iftext, ifdata );
    end
end

function insertData()
	%Not implemented.
end
