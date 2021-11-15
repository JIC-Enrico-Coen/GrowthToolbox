function s = printModelOptions( fid, m, reportOptions )
%printModelOptions( m )
%printModelOptions( fid, m )
%printModelOptions( fid, m, optionnames )
%   Print the current model options to the given stream (by default the
%   console). If optionnames is given it should be a cell array of option
%   names, specifying that only those options are to be printed.

    if nargin==1
        m = fid;
        fid = 1;
    end
    if ~isfield( m, 'modeloptions' )
        return;
    end
    mo = m.modeloptions;
    if nargin >=3
        notprinted = setdiff( fieldnames(mo), reportOptions );
        mo = safermfield( mo, notprinted );
    end

    if fid >= 0
        fprintf( fid, 'Model options:\n' );
    end
    
    if nargout == 0
        printOptions( fid, mo );
    else
        s = printOptions( fid, mo );
    end
end
